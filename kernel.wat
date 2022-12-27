(module

 (import "memory" "main" (memory 1))

 (import "algorithms" "bisect-left-i64"
         (func $bisect-left-i64 (param i32 i32 i32)))

 (import "algorithms" "hoare-quicksort-i64"
         (func $hoare-quicksort-i64 (param i32 i32 i32)))

 ;; Pairs
 ;;
 ;; Pairs are the fundamental data type, from which values of all other types
 ;; are referenced.

 ;; Blockstore, pairs, refindex.

 ;; Memory
 ;;
 ;; There are (currently) four kinds of pages, all are 64KB: the 0 page which
 ;; contains global information about what each page contains and the system as
 ;; a whole.  Pair memory pages contain pairs managed by tracing at deletions
 ;; and a reverse reference index.  Index pages contain a sorted array of
 ;; reverse reference entries.  Block allocation pages hold storage for vectors,
 ;; strings, and bytearrays.  A page for io or shared memory buffers may also
 ;; prove useful.
 ;;
 ;; Pair memory pages are contiguous just above the 0 page, followed by an
 ;; unused page that will become the next pair memory page, and finally by the
 ;; index pages in a contiguous sequence. Each time a new pair memory page is
 ;; initialized, a corresponding index page is initialized. The new index page
 ;; is created such that it starts one page above the end of the previously
 ;; final index page.  This one-page gap is slowly closed by copying small
 ;; numbers of entries from the top of the lower part of the index to the bottom
 ;; of the upper part, a few at each allocation, such that by the earliest time
 ;; at which the highest memory page could be full, there is an empty page above
 ;; it. Generally this means copying as many entries as there are memory pages
 ;; currently in use.
 ;;
 ;; Pair memory is organized into several sections.  The lowest 64 bytes hold
 ;; the page attributes.  Above 64 bytes, but below 2048 are the pair state
 ;; flags.  Each pair above 2048 has two bits in the pair flags area,
 ;; representing one of three states of the pair: unallocated, pending a trace,
 ;; and known to be reachable.  The first pair of the page is the head of the
 ;; free-list.  The remainder of the page is composed of pairs available for use.
 ;;
 ;; Index pages contain a sorted array of index entries. Each entry contains
 ;; either two pair addresses, or a pair address and #null.  If the second
 ;; address is null, then it is an empty entry, either the result of a deletion
 ;; or an expansion of the index.  If the second is not #null, then the entry
 ;; represents a relationship between the two pairs, where the pair at the first
 ;; address is referenced by the second in some way, either in its car or
 ;; cdr. The index allows empty entries to enable fast deletes, and maintains a
 ;; minimum proportion of empty entries to allow inserts to be relatively fast,
 ;; only needing to move some small number of entries to make room for a new
 ;; one.  Ideally, there will be an empty entry every k cells or so, where k is
 ;; some small positive number.  At present, there is no mechanism to enforce an
 ;; even distribution of empty entries, though it could be part of the expansion
 ;; algorithm.
 ;;
 ;; The 0 page maintains an active memory page. Allocation requests are directed
 ;; to this page. The active page may have an open frontier, or it may be
 ;; allocating from its free-list. A page has an open frontier when the lowest
 ;; address allocated pair is above the highest allocated pair in the block
 ;; list. When the page has an open frontier, allocation simply takes the next
 ;; lower pair. After the frontier has closed, the page uses its free-list. The
 ;; free-list is a stack that builds down from the pair flags area to just above
 ;; the page attributes. When the free-list is empty, the page scans the pair
 ;; flags area by groups of 64 bits (that, is 32 pairs), starting from high
 ;; memory to low. Any free pairs have their offsets added to the pair list.
 ;; When the page is fully allocated, the frontier allocator returns #null,
 ;; triggering the main allocator to activate the next page.  Each return pair
 ;; is marked in the pair flags area as pending a scan for reachablilty.
 ;;
 ;; When a reference to a system root, a pair, or a vector is changed, the
 ;; transitive closure of the old target of the reference is immediately marked
 ;; as uncertain.
 ;;
 ;; Each pair occupies two machine words. In the current implementation of i32,
 ;; this equates to 8 bytes per pair. For each pair, there are two bits reserved
 ;; in the lower 2KB to indicate whether the pair is free, and if not, what
 ;; color it currently has been assigned by the garbage collector (tricolor,
 ;; incremental, tracing).
 ;;
 ;; At 2 bits per 8 byte pair, 2/64 = 1/32 of the page will be used for memory
 ;; management. But since the lower 2KB are used for memory management, we don't
 ;; need free/color bits for those 2KB. At 8 bytes per pair, that 2048 would be
 ;; 256 pairs, so the lower 512 bits = 64 bytes are free for other uses.
 ;;

 (global $offset-size (export "offset-size") i32 (i32.const 2))
 (global $value-size  (export "value-size")  i32 (i32.const 4))
 (global $pair-size   (export "pair-size")   i32 (i32.const 8))
 (global $group-size  (export "group-size")  i32 (i32.const 8))
 (global $page-size   (export "page-size")   i32 (i32.const 0x10000))

 (global $offset-size-bits (export "offset-size-bits") i32 (i32.const 1))
 (global $value-size-bits  (export "value-size-bits")  i32 (i32.const 2))
 (global $pair-size-bits   (export "pair-size-bits")   i32 (i32.const 3))
 (global $group-size-bits  (export "group-size-bits")  i32 (i32.const 3))
 (global $page-size-bits   (export "page-size-bits")   i32 (i32.const 16))

 (global $initial-pairs-bottom (export "initial-pairs-bottom") i32 (i32.const 0x00000000))
 (global $initial-pairs-top    (export "initial-pairs-top")    i32 (i32.const 0x00010000))

 (global $initial-blocks-bottom (export "initial-blocks-bottom") i32 (i32.const 0x00010000))
 (global $initial-blocks-top    (export "initial-blocks-top")    i32 (i32.const 0x00020000))

 (global $pairs-bottom                  (export "pairs-bottom")                  (mut i32) (i32.const 0xffffffff))
 (global $pairs-top                     (export "pairs-top")                     (mut i32) (i32.const 0xffffffff))
 (global $pair-count                    (export "pair-count")                    (mut i32) (i32.const 0x00000000))
 (global $pair-free-list                (export "pair-free-list")                (mut i32) (i32.const 0xffffffff))
 (global $blocks-bottom             (export "blocks-bottom")             (mut i32) (i32.const 0xffffffff))
 (global $blocks-top                (export "blocks-top")                (mut i32) (i32.const 0xffffffff))
 (global $block-count        (export "block-count")        (mut i32) (i32.const 0x00000000))
 (global $blocks-relocation-offset  (export "blocks-relocation-offset")  (mut i32) (i32.const 0x00000000))
 (global $blocks-relocation-end     (export "blocks-relocation-end")     (mut i32) (i32.const 0xffffffff))
 (global $blocks-current-relocation (export "blocks-current-relocation") (mut i32) (i32.const 0xffffffff))
 (global $blocks-free-area          (export "blocks-free-area")          (mut i32) (i32.const 0xffffffff))

 ;; Block structure

 (global $block-owner           (export "block-owner")           i32 (i32.const 0x0000))
 (global $block-length          (export "block-length")          i32 (i32.const 0x0004))
 (global $free-block-next-block (export "free-block-next-block") i32 (i32.const 0x0008))

 ;; Sizes and lengths

 (global $block-header-length    (export "block-header-length")    i32 (i32.const 2))
 (global $block-header-size      (export "block-header-size")      i32 (i32.const 0x0008))

 ;; Refindex

 (global $index-entry-size      (export "index-entry-size")      i32 (i32.const 8))
 (global $index-entry-length    (export "index-entry-length")    i32 (i32.const 2))

 ;;
 (global $sep-list              (export "ref-list")              (mut i32) (i32.const 0))
 (global $ref-list              (export "ref-list")              (mut i32) (i32.const 0))
 (global $ref-list-length       (export "ref-list-length")       (mut i32) (i32.const 0))
 (global $refindex-generations-list (export "refindex-generations-list") i32 (i32.const 0x0000))

 ;;=============================================================================
 ;;
 ;; Values
 ;;
 ;; Each pair contains two values.  These are tagged to indicate what kind of
 ;; value they hold.  The tag occupies the low 3 bits of the value.
 ;;
 ;; The rationale for the tag assignments below follows from an attempt to
 ;; arrange small integer arithmetic and pair dereferencing as to be as
 ;; efficient as possible.
 ;;
 ;; Small integer considerations are that the small integer tag is 0, and that
 ;; the tag bits are in the low bits of the word.  Together these allow small
 ;; integer operations without any shifts or masking.
 ;;
 ;; The allowance for pairs is the 3 bit tag.  With 4 byte words, and therefore
 ;; 8 byte pairs, all pair addresses will have the lower 3 bits 0. Hence, to
 ;; transform a pair value to a pair address only requires a mask.
 ;;
 ;; Small integers are numbers that fit within 2^29, should an operation cause
 ;; an overflow, the value will be automatically promoted to a block value,
 ;; encoding the number as an arbitrary-precision integer.
 ;;
 ;; Blocks contain the address of a pair.  The first value in the pair contains
 ;; a type designator, the second value contains the address of a block in the
 ;; blockstore.  The pair referenced by a block value is the owner of the block
 ;; in the blockstore, and every block has exactly one such owner.  Some blocks
 ;; may be empty -- such as a vector of length zero -- in which case the block
 ;; address will be $null.  Type designators are a small enumeration which
 ;; includes values for bytearrays, numbers, strings, and vectors.
 ;;
 ;; Boxes contain the address of a pair, similar to blocks.  They also have a
 ;; type designator in the first value and an address in the second.  Currently,
 ;; the only purpose envisioned for these is to hold a weak reference.  Another
 ;; possibility would be an opaque 32-bit value from an external source.  This
 ;; would be unsafe to put in an ordinary pair, and much less efficient to store
 ;; in a bytearray. Small strings or bytearrays could also fit, packed as
 ;;
 ;;     0               1                | 0               1
 ;;     0123456789abcdef0123456789abcdef | 0123456789abcdef0123456789abcdef
 ;;     | type  | count | char1 | char2 |  | char3 | char4 | char5 | char6 |
 ;;
 ;; Procedures. TBD.
 ;;
 ;; A symbol is an index into the symbol table. The symbol table is a private
 ;; vector which contains string values, sorted lexicographically.
 ;;
 ;; Singletons are one of the following: #true, #false, #null, #eof-object

 (global $value-tag-mask  (export "tag-mask")  i32 (i32.const 0x00000007))
 (global $value-data-mask (export "data-mask") i32 (i32.const 0xfffffff8))

 (global $tag-small-integer (export "tag-small-integer") i32 (i32.const 0x00))
 (global $tag-block         (export "tag-block")         i32 (i32.const 0x01))
 (global $tag-box           (export "tag-box")           i32 (i32.const 0x02))
 (global $tag-char          (export "tag-char")          i32 (i32.const 0x03))
 (global $tag-pair          (export "tag-pair")          i32 (i32.const 0x04))
 (global $tag-procedure     (export "tag-procedure")     i32 (i32.const 0x05))
 (global $tag-symbol        (export "tag-symbol")        i32 (i32.const 0x06))
 (global $tag-singleton     (export "tag-singleton")     i32 (i32.const 0x07))

 ;; Singletons

 (global $eof            (export "#eof-object")    i32 (i32.const 0xeee00fff))
 (global $false          (export "#false")         i32 (i32.const 0x00000007))
 (global $null           (export "#null")          i32 (i32.const 0xffffffff))
 (global $true           (export "#true")          i32 (i32.const 0x0000000f))
 (global $type-bytearray (export "type-bytearray") i32 (i32.const 0x00010007))
 (global $type-number    (export "type-number")    i32 (i32.const 0x00010017))
 (global $type-string    (export "type-string")    i32 (i32.const 0x00010027))
 (global $type-vector    (export "type-vector")    i32 (i32.const 0x0001003f))

 (global $singleton-type-mask       (export "singleton-type-mask")       i32 (i32.const 0xffff0007))
 (global $singleton-type-null       (export "singleton-type-null")       i32 (i32.const 0xffff0007))
 (global $singleton-type-boolean    (export "singleton-type-boolean")    i32 (i32.const 0x00000007))
 (global $singleton-type-eof        (export "singleton-type-eof")        i32 (i32.const 0xeee00007))
 (global $singleton-type-block-type (export "singleton-type-block-type") i32 (i32.const 0x00010007))

 (func $get-value-tag (export "value-tag")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $value-tag-mask)))

 (func $get-value-data (export "value-data")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $value-data-mask)))

 (func $make-value (export "make-value")
   (param $tag i32)
   (param $data i32)
   (result i32)
   (i32.or (local.get $tag) (local.get $data)))

 (func $make-value-safely (export "make-value-safely")
   (param $tag i32)
   (param $data i32)
   (result i32)
   (i32.or (i32.and (local.get $tag) (global.get $value-tag-mask))
           (i32.and (local.get $data) (global.get $value-data-mask))))

 (func $is-pair-value (export "is-pair-value")
   (param $value i32)
   (result i32)
   (i32.eq (call $get-value-tag (local.get $value)) (global.get $tag-pair)))

 (func $is-singleton-block-type (export "is-singleton-block-type")
   (param $value i32)
   (result i32)
   (i32.eq (i32.and (local.get $value)
                    (global.get $singleton-type-mask))
           (global.get $singleton-type-block-type)))

 ;;=============================================================================
 ;;
 ;; Pairs
 ;;

 (func $get-pair-addr (export "get-pair-addr")
   (param $pair i32)
   (result i32)
   (local.get $pair))

 (func $get-pair-car (export "get-pair-car")
   (param $pair i32)
   (result i32)
   (i32.load (local.get $pair)))

 (func $get-pair-cdr (export "get-pair-cdr")
   (param $pair i32)
   (result i32)
   (i32.load (i32.add (local.get $pair)
                      (global.get $value-size))))

 (func $get-pair-values (export "get-pair-values")
   (param $pair i32)
   (result i32 i32)
   (i32.load (i32.add (local.get $pair)
                      (global.get $value-size)))
   (i32.load (local.get $pair)))

 (func $get-pair-car-addr (export "get-pair-car-addr")
   (param $pair i32)
   (result i32)
   (local.get $pair))

 (func $get-pair-cdr-addr (export "get-pair-cdr-addr")
   (param $pair i32)
   (result i32)
   (i32.add (local.get $pair)
            (global.get $value-size)))

 (func $set-pair-car (export "set-pair-car")
   (param $pair i32)
   (param $value i32)
   (i32.store (local.get $pair)
              (local.get $value)))

 (func $set-pair-cdr (export "set-pair-cdr")
   (param $pair i32)
   (param $value i32)
   (i32.store (i32.add (local.get $pair)
                       (global.get $value-size))
              (local.get $value)))

 (func $is-pair-block-owner (export "is-pair-block-owner")
   (param $pair i32)
   (result i32)
   (call $is-singleton-block-type (call $get-pair-car (local.get $pair))))

 ;;=============================================================================
 ;;
 ;; Block values
 ;;

 (global $block-value-type  (export "block-value-type")  i32 (i32.const 0x0000))
 (global $block-value-block (export "block-value-block") i32 (i32.const 0x0004))

 (func $get-block-value-type (export "get-block-value-type")
   (param $block-value i32)
   (result i32)
   (i32.load (i32.add (local.get $block-value)
                      (global.get $block-value-type))))

 (func $get-block-value-block (export "get-block-value-block")
   (param $block-value i32)
   (result i32)
   (i32.load (i32.add (local.get $block-value)
                      (global.get $block-value-block))))

 (func $set-block-value-type (export "set-block-value-type")
   (param $block-value i32)
   (param $block i32)
   (i32.store (i32.add (local.get $block-value)
                       (global.get $block-value-type))
              (local.get $block)))

 (func $set-block-value-block (export "set-block-value-block")
   (param $block-value i32)
   (param $block i32)
   (i32.store (i32.add (local.get $block-value)
                       (global.get $block-value-block))
              (local.get $block)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Accessors
 ;;

 (func $get-block-owner (export "get-block-owner")
   (param $block i32)
   (result i32)
   (i32.load (i32.add (local.get $block)
                      (global.get $block-owner))))

 (func $get-block-elements (export "get-block-elements")
   (param $block i32)
   (result i32)
   (i32.add (local.get $block)
            (global.get $block-header-size)))

 (func $get-block-elements-end (export "get-block-elements-end")
   (param $block i32)
   (result i32)
   (i32.add (call $get-block-elements (local.get $block))
            (i32.mul (call $get-block-length (local.get $block))
                     (global.get $value-size))))

 (func $get-block-length (export "get-block-length")
   (param $block i32)
   (result i32)
   (i32.load (i32.add (local.get $block)
                      (global.get $block-length))))

 (func $get-next-element (export "get-next-element")
   (param $element i32)
   (result i32)
   (i32.add (local.get $element) (global.get $value-size)))

 (func $get-next-free-block (export "get-next-free-block")
   (param $block i32)
   (result i32)
   (i32.load (i32.add (local.get $block)
                      (global.get $free-block-next-block))))

 (func $set-block-owner (export "set-block-owner")
   (param $block i32)
   (param $owner i32)
   (i32.store (i32.add (local.get $block)
                       (global.get $block-owner))
              (local.get $owner)))

 (func $set-block-length (export "set-block-length")
   (param $block i32)
   (param $length i32)
   (i32.store (i32.add (local.get $block)
                       (global.get $block-length))
              (local.get $length)))

 (func $set-next-free-block (export "set-next-free-block")
   (param $block i32)
   (param $next-block i32)
   (i32.store (i32.add (local.get $block)
                       (global.get $free-block-next-block))
              (local.get $next-block)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Utilities
 ;;

 (func $calc-block-size (export "calc-block-size")
   (param $length i32)
   (result i32)
   (i32.add (global.get $block-header-size)
            (i32.shl (local.get $length)
                     (global.get $value-size-bits))))

 (func $get-block-size (export "get-block-size")
   (param $block i32)
   (result i32)

   (i32.add (global.get $block-header-size)
            (i32.shl (call $get-block-length (local.get $block))
                     (global.get $value-size-bits))))

 (func $get-next-block (export "get-next-block")
   (param $block i32)
   (result i32)
   (i32.add (local.get $block)
            (call $get-block-size (local.get $block))))

 (func $is-free-block (export "is-free-block")
   (param $block i32)
   (result i32)
   (i32.eq (call $get-block-owner (local.get $block)) (global.get $null)))

 (func $is-last-free-block (export "is-last-free-block")
   (param $block i32)
   (result i32)
   (i32.eq (call $get-next-free-block (local.get $block)) (global.get $null)))

 (func $make-free-block (export "make-free-block")
   (param $block i32)
   (param $length i32)
   (param $next-block i32)

   (call $set-block-owner     (local.get $block) (global.get $null))
   (call $set-block-length    (local.get $block) (local.get $length))
   (call $set-next-free-block (local.get $block) (local.get $next-block)))

 ;;=============================================================================
 ;;
 ;; Vectors
 ;;

 (func $get-vector-length (export "get-vector-length")
   (param $v i32)
   (result i32)
   (local $block i32)
   (local.set $block (call $get-block-value-block (local.get $v)))
   (if (result i32) (i32.eq (local.get $block) (global.get $null))
     (then
      (i32.const 0))
     (else
      (call $get-block-length (local.get $block)))))

 (func $get-vector-elements (export "get-vector-elements")
   (param $v i32)
   (result i32)
   (local $block i32)
   (local.set $block (call $get-block-value-block (local.get $v)))
   (if (result i32) (i32.eq (local.get $block) (global.get $null))
     (then
      (global.get $null))
     (else
      (call $get-block-elements (local.get $block)))))

 (func $get-vector-elements-end (export "get-vector-elements-end")
   (param $v i32)
   (result i32)
   (local $block i32)
   (local.set $block (call $get-block-value-block (local.get $v)))
   (if (result i32) (i32.eq (local.get $block) (global.get $null))
     (then
      (global.get $null))
     (else
      (call $get-block-elements-end (local.get $block)))))

 (func $is-vector-value (export "is-vector-value")
   (param $value i32)
   (result i32)
   (if (result i32) (i32.eq (call $get-value-tag (local.get $value))
                            (global.get $tag-block))
     (then
      (i32.eq (call $get-block-value-type (local.get $value))
              (global.get $block-value-type-vector)))
     (else
      (i32.const 0))))

 ;;=============================================================================
 ;;
 ;; Box values
 ;;

 (global $box-value-type  (export "box-value-type")  i32 (i32.const 0x0000))
 (global $box-value-value (export "box-value-value") i32 (i32.const 0x0004))

 (global $box-value-type-weakref (export "box-value-type-weakref") i32 (i32.const 0))

 (func $get-box-value-type (export "get-box-value-type")
   (param $box-value i32)
   (result i32)
   (i32.load (i32.add (local.get $box-value)
                      (global.get $box-value-type))))

 (func $get-box-value-value (export "get-box-value-value")
   (param $box-value i32)
   (result i32)
   (i32.load (i32.add (local.get $box-value)
                      (global.get $box-value-value))))

 (func $set-box-value-type (export "set-box-value-type")
   (param $box-value i32)
   (param $box i32)
   (i32.store (i32.add (local.get $box-value)
                       (global.get $box-value-type))
              (local.get $box)))

 (func $set-box-value-value (export "set-box-value-value")
   (param $box-value i32)
   (param $box i32)
   (i32.store (i32.add (local.get $box-value)
                       (global.get $box-value-value))
              (local.get $box)))

 ;;=============================================================================
 ;;
 ;; Refindex
 ;;
 ;; The refindex is an index that tracks references from pairs to pairs.  It is
 ;; used to relocate pairs as memory needs grow, and to determine which pairs
 ;; are unreachable.
 ;;
 ;; It is a sorted array of 8 byte entries. The first 4 bytes are the address of
 ;; a pair -- though it may be a pair that has not yet been allocated or was
 ;; previously deallocated -- and the second 4 bytes is the address of the pair
 ;; that refers to it.  The second 4 bytes may be $null, in which case the entry
 ;; is considered empty.  If the first 4 bytes is not an allocated pair, then
 ;; the second 4 bytes must be $null.
 ;;
 ;; The array is initialized to empty entries in the range that will be used by
 ;; the first pairs that will be allocated.  As the refindex grows, it is
 ;; periodically rewritten to ensure that there are empty entries distributed
 ;; throughout, so that insertions do not involve too much copying.
 ;;
 ;; Since the refindex is stored in memory above the pairs, it must be relocated
 ;; from time to time as the requirements for pair storage expand.  When the
 ;; refindex is being relocated, it is split into two smaller arrays, one in the
 ;; position the refindex is moving to, the other in the old position.

 (func $init-refindex (export "init-refindex")
   nop)

 (func $extend-refindex (export "extend-refindex")
   nop)

 (func $insert-refindex-entry (export "insert-refindex-entry")
   (param $pair i32)
   (param $ref i32)
   nop)

 (func $remove-refindex-entry (export "remove-refindex-entry")
   (param $pair i32)
   (param $ref i32)
   nop)

 ;;=============================================================================
 ;;
 ;; Pairs
 ;;
 ;; The pairs is comprised of a few scalar values in the system area, and
 ;; three data structures: pair flags and the free-list.  The
 ;; free-list is a linked list of pairs which are available for allocation.  The
 ;; link to the next pair in the free-list is in the first value; the second
 ;; value is not used.  The pair flags is a bitarray where each pair gets two
 ;; bits, each representing one of three states the pair can be in: unallocated,
 ;; not known to be reachable (uncertain), and known to be reachable.
 ;;

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Accessors
 ;;

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Flags
 ;;
 ;; There are two sets of flags which describe the state of pairs. The first set
 ;; are referred to as the pair flags.  These consist of a contiguous block of
 ;; memory holding two bits per pair.  The flags indicate whether the pair is
 ;; possibly separated from all known reachable pairs, and whether it is known
 ;; to be reachable.  The second set are the smudge flags.  These consist of
 ;; another contiguous block of memory holding one bit per group of 64 pair flag
 ;; bits.  A set smudge flag indicates that the corresponding pair flag group
 ;; contains a pair flag set which is allocated but not known to be reachable

 (global $pair-flag-reachable (export "pair-flag-reachable") i32 (i32.const 1))
 (global $pair-flag-separated (export "pair-flag-separated") i32 (i32.const 2))
 (global $pair-flags-mask     (export "pair-flags-mask")     i32 (i32.const 0x00000003))

 (global $pair-flag-reachable-i64-group i64 (i64.const 0x5555555555555555))
 (global $pair-flag-separated-i64-group i64 (i64.const 0xaaaaaaaaaaaaaaaa))

 ;; The pair flag address shift is the number of bit positions the pair offset
 ;; is shifted right to get the offset of the byte containing the flag bits
 ;; for the pair in the containing page's memory map. Since the memory map
 ;; has two bits per 8 byte pair, the ratio of the first to the second is 1/32,
 ;; hence the shift is log2 32 = 5.
 (global $pair-flag-addr-shift (export "pair-flag-addr-shift") i32 (i32.const 5))

 ;; The 5 lowest bits will be shifted out when the pair flag address shift
 ;; is applied. The three lower of these 5 bits will be zero, since pairs
 ;; are 8 bytes and 8 byte aligned. The upper two of those 5 bits provide
 ;; the index into the flag byte.
 (global $pair-flag-idx-mask (export "pair-flag-idx-mask") i32 (i32.const 0x18))

 ;; The pair flag idx shift is the number of bit positions the pair offset
 ;; is shifted right to get the index of the flag bits within the flag byte.
 ;; Since there are 2 bits per pair, there will be 4 sets of flag bits per
 ;; byte. Pair addresses that end with 0x8 should be mapped to bit position
 ;; 2, giving a shift of 2.
 (global $pair-flag-idx-shift  (export "pair-flag-idx-shift") i32 (i32.const 2))

 (func $get-pair-flags-block-addr (export "get-pair-flags-block-addr")
   (call $get-block-elements (call $get-block-value-block
                                   (global.get $pair-flags-block))))

 (func $get-pair-flags-location (export "get-pair-flags-location")
   (param $pair i32)
   (result i32 i32)

   (i32.add (i32.shr_u (local.get $pair)
                       (global.get $pair-flag-addr-shift))
            (call $get-pair-flags-block-addr))

   (i32.shr_u (i32.and (local.get $pair)
                       (global.get $pair-flag-idx-mask))
              (global.get $pair-flag-idx-shift)))

 (func $get-pair-flags (export "get-pair-flags")
   (param $pair i32)
   (result i32)

   (local $addr i32)
   (local $shift-count i32)

   (local.set $addr
              (local.set $shift-count
                         (call $get-pair-flags-location
                               (local.get $pair))))

   (i32.and (i32.shr_u (i32.load8_u (local.get $addr))
                       (local.get $shift-count))
            (global.get $pair-flags-mask)))

 (func $replace-pair-flags (export "replace-pair-flags")
   ;; Sets the pair flags to the given 2-bit value $flag. This may clear flag
   ;; bits.
   (param $pair i32)
   (param $flag i32)

   (local $addr i32)
   (local $extant-flags i32)
   (local $new-flags i32)
   (local $shift-count i32)

   (local.set $addr
              (local.set $shift-count
                         (call $get-pair-flags-location
                               (local.get $pair))))

   (local.set $flag (i32.and (local.get $flag)
                             (global.get $pair-flags-mask)))

   (local.set $extant-flags
              (i32.and (i32.load8_u (local.get $addr))
                       (i32.xor (i32.const -1)
                                (i32.shl (global.get $pair-flags-mask)
                                         (local.get $shift-count)))))
   (local.set $new-flags
              (i32.shl (i32.and (local.get $flag)
                                (global.get $pair-flags-mask))
                       (local.get $shift-count)))

   (i32.store8 (local.get $addr)
               (i32.or (local.get $extant-flags)
                       (local.get $new-flags))))

 (func $set-pair-flag (export "set-pair-flag")
   ;; Sets pair flags to true. This will not clear any flags.
   (param $pair i32)
   (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)

   (local.set $addr
              (local.set $shift-count
                         (call $get-pair-flags-location
                               (local.get $pair))))

   (i32.store8 (local.get $addr)
               (i32.or (i32.load8_u (local.get $addr))
                       (i32.shl (i32.and (local.get $flag)
                                         (global.get $pair-flags-mask))
                                (local.get $shift-count)))))

 (func $clear-pair-flag (export "clear-pair-flag")
   (param $pair i32)
   (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)

   (local.set $addr
              (local.set $shift-count
                         (call $get-pair-flags-location
                               (local.get $pair))))

   (i32.store8 (local.get $addr)
               (i32.and (i32.load8_u (local.get $addr))
                        (i32.xor (i32.const -1)
                                 (i32.shl (i32.and (local.get $flag)
                                                   (global.get $pair-flags-mask))
                                          (local.get $shift-count))))))

 (func $get-group-reachable-pair-map (export "get-group-reachable-pair-map")
   (param $flags i64)
   (result i64)

   (i64.shr_u (i64.and (global.get $pair-flag-reachable-i64-group)
                        (local.get $flags))
               (i64.const 1)))

 (func $get-group-separated-pair-map (export "get-group-separated-pair-map")
   (param $flags i64)
   (result i64)

   (i64.and (global.get $pair-flag-separated-i64-group)
            (local.get $flags)))

 (func $mark-pair-separated (export "mark-pair-separated")
   (param $value i32)

   (global.set $separated-pair-count (i32.add (global.get $separated-pair-count)
                                              (i32.const 1)))

   (call $replace-pair-flags
         (local.get $value)
         (global.get $pair-flag-separated)))

 (func $is-marked-reachable (export "is-marked-reachable")
   (param $value i32)
   (result i32)

   (i32.and (call $get-pair-flags (local.get $value))
            (global.get $pair-flag-reachable)))

 (func $is-marked-separated (export "is-marked-separated")
   (param $value i32)
   (result i32)

   (i32.and (call $get-pair-flags (local.get $value))
            (global.get $pair-flag-separated)))

 (func $get-flag-group-pair-offset (export "get-flag-group-pair-offset")
   (param $group i32)
   (result i32)

   (i32.shl (local.get $group)
            (global.get $pair-flag-addr-shift)))

 (func $next-pair-offset (export "next-pair-offset")
   (param $pair-map i64)
   (param $pair-offset i32)
   (result i64 i32)

   (local $i i64)

   (local.set $i (i64.ctz (local.get $pair-map)))

   (if (result i64) (i64.lt_u (local.get $i) (i64.const 62))
     (then
      ;; shift the pair map right by $i + 2 to consume the trailing zeros, the
      ;; lowest set bit, and the zero immediately above it
      (i64.shr_u (local.get $pair-map)
                 (i64.add (i64.const 2) (local.get $i))))

     (else
      ;; if $i == 62, then it's a group with just the high pair. In that case,
      ;; the shr_u of 62+2 becomes a nop, and bad things happen.
      (i64.const 0)))

   (i32.add (local.get $pair-offset)
            (i32.mul (i32.const 4)
                     (i32.wrap_i64 (local.get $i)))))

 (func $trace-flag-group-mark-separated (export "trace-flag-group-mark-separated")
   (param $page i32)
   (param $group i32)

   (local $pair-addr i32)
   (local $pair-map i64)

   (call $clear-separated-flag-group (local.get $group))

   (local.set $pair-map
              (call $get-separated-pair-group-map
                    (i64.load (local.get $group))))

   (local.set $pair-addr (call $get-pair-group-base-addr (local.get $group)))

   (loop $again
     (if (i64.ne (local.get $pair-map) (i64.const 0))
         (then

          (local.set $pair-map
                     (local.set $pair-addr
                                (call $next-pair-addr
                                      (local.get $pair-map)
                                      (local.get $pair-addr))))

          (call $trace-value-mark-separated (call $get-pair-car (local.get $pair-addr)))
          (call $trace-value-mark-separated (call $get-pair-cdr (local.get $pair-addr)))

          (local.set $pair-addr (i32.add (local.get $pair-addr) (global.get $pair-size)))

          (br $again)))))

 (func $trace-flag-group-mark-reachable (export "trace-flag-group-mark-reachable")
   (param $page i32)
   (param $group i32)

   (local $pair-addr i32)
   (local $pair-map i64)

   (call $clear-reachable-flag-group (local.get $group))

   (local.set $pair-map
              (call $get-reachable-pair-group-map
                    (i64.load (local.get $group))))

   (local.set $pair-addr (call $get-pair-group-base-addr (local.get $group)))

   (loop $again
     (if (i64.ne (local.get $pair-map) (i64.const 0))
         (then

          (local.set $pair-map
                     (local.set $pair-addr
                                (call $next-pair-addr
                                      (local.get $pair-map)
                                      (local.get $pair-addr))))

          (call $trace-value-mark-reachable (call $get-pair-car (local.get $pair-addr)))
          (call $trace-value-mark-reachable (call $get-pair-cdr (local.get $pair-addr)))

          (local.set $pair-addr (i32.add (local.get $pair-addr) (global.get $pair-size)))

          (br $again)))))

 (func $trace-value-dealloc-unreachable (export "trace-value-dealloc-unreachable")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $get-value-tag (local.get $value)))

   (if (i32.eq (local.get $tag) (global.get $tag-pair))
       (then
        (if (call $is-marked-separated (local.get $value))
            (then
             (if (call $is-pair-reachable (local.get $value))
                 (then
                  (call $trace-value-mark-reachable (local.get $value)))
               (else
                (call $dealloc-pair (local.get $value))
                (call $refindex-delete-pair-entries (local.get $value))
                (call $trace-value-dealloc-unreachable (call $get-pair-car (local.get $value)))
                (call $trace-value-dealloc-unreachable (call $get-pair-cdr (local.get $value))))))))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-block))
          (then
           (if (call $is-marked-separated (local.get $value))
               (then
                (if (call $is-pair-reachable (local.get $value))
                    (then
                     (call $trace-block-mark-reachable (local.get $value)))
                  (else
                   (call $dealloc-block-value (local.get $value))
                   (call $refindex-delete-pair-entries (local.get $value))
                   (call $trace-block-dealloc-unreachable (local.get $value)))))))))))

 (func $trace-value-mark-reachable (export "trace-value-mark-reachable")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $get-value-tag (local.get $value)))

   (if (i32.eq (local.get $tag) (global.get $tag-pair))
       (then
        (if (call $is-marked-separated (local.get $value))
            (then
             (call $mark-pair-reachable (local.get $value))
             (call $trace-value-mark-reachable (call $get-pair-car (local.get $value)))
             (call $trace-value-mark-reachable (call $get-pair-cdr (local.get $value))))))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-block))
          (then
           (if (call $is-marked-separated (local.get $value))
               (then
                (call $mark-pair-reachable (local.get $value))
                (call $trace-block-mark-reachable (local.get $value)))))))))

 (func $trace-value-mark-separated (export "trace-value-mark-separated")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $get-value-tag (local.get $value)))

   (if (i32.eq (local.get $tag) (global.get $tag-pair))
       (then
        (if (call $is-marked-reachable (local.get $value))
            (then
             (call $mark-pair-separated (local.get $value))
             (call $trace-value-mark-separated (call $get-pair-car (local.get $value)))
             (call $trace-value-mark-separated (call $get-pair-cdr (local.get $value))))))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-block))
          (then
           (if (call $is-marked-reachable (local.get $value))
               (then
                (call $mark-pair-separated (local.get $value))
                (call $trace-block-mark-separated (local.get $value)))))))))

 (func $trace-block-dealloc-unreachable (export "trace-block-dealloc-unreachable")
   (param $block-value i32)

   (local $block i32)
   (local $element i32)
   (local $end-element i32)
   (local $value i32)

   (local.set $block (call $get-block-value-block (local.get $block-value)))

   (if (i32.and (i32.eq (call $get-block-value-type (local.get $block-value))
                        (global.get $block-value-type-vector))
                (i32.ne (local.get $block) (global.get $null)))
       (then
        (local.set $end-element (call $get-block-elements-end (local.get $block)))
        (loop $again
          (if (i32.lt_u (local.get $element) (local.get $end-element))
              (then
               (call $trace-value-dealloc-unreachable (i32.load (local.get $element)))
               (local.set $element (call $get-next-element (local.get $element)))
               (br $again))))
        (call $dealloc-block (local.get $block)))))

 (func $trace-block-mark-separated (export "trace-block-mark-separated")
   (param $block-value i32)

   (local $block i32)
   (local $element i32)
   (local $end-element i32)
   (local $value i32)

   (local.set $block (call $get-block-value-block (local.get $block-value)))

   (if (i32.and (i32.eq (call $get-block-value-type (local.get $block-value))
                        (global.get $block-value-type-vector))
                (i32.ne (local.get $block) (global.get $null)))
       (then
        (local.set $end-element (call $get-block-elements-end (local.get $block)))
        (loop $again
          (if (i32.lt_u (local.get $element) (local.get $end-element))
              (then
               (call $trace-value-mark-separated (i32.load (local.get $element)))
               (local.set $element (call $get-next-element (local.get $element)))
               (br $again)))))))


 (func $trace-block-mark-reachable (export "trace-block-mark-reachable")
   (param $block-value i32)

   (local $block i32)
   (local $element i32)
   (local $end-element i32)
   (local $value i32)

   (local.set $block (call $get-block-value-block (local.get $block-value)))

   (if (i32.and (i32.eq (call $get-block-value-type (local.get $block-value))
                        (global.get $block-value-type-vector))
                (i32.ne (local.get $block) (global.get $null)))
       (then
        (local.set $end-element (call $get-block-elements-end (local.get $block)))
        (loop $again
          (if (i32.lt_u (local.get $element) (local.get $end-element))
              (then
               (call $trace-value-mark-reachable (i32.load (local.get $element)))
               (local.set $element (call $get-next-element (local.get $element)))
               (br $again)))))))


 ;;=============================================================================
 ;;
 ;; Pair Manager Initialization
 ;;

 (func $init-pairs (export "init-pairs")
   (param $bottom i32)
   (param $top i32)

   (global.set $pairs-bottom (local.get $bottom))
   (global.set $pairs-top (local.get $top))
   (global.set $pair-count (i32.const 0))
   (global.set $pair-free-list (global.get $null))

   (call $clear-pair-flags-area (local.get $bottom) (local.get $top))

   (call $fill-pair-free-list (local.get $bottom) (local.get $top)))

 (func $clear-pair-flags-area (export "clear-pair-flags-area")
   (param $bottom i32)
   (param $top i32)

   (local $flags-bottom i32)
   (local $flags-top i32)

   (local.set $flags-bottom (i32.shr_u (local.get $bottom)
                                       (global.get $pair-flag-addr-shift)))

   (local.set $flags-top (i32.shr_u (local.get $top)
                                    (global.get $pair-flag-addr-shift)))

   (memory.fill
    (local.get $flags-bottom)
    (i32.const 0)
    (i32.sub (local.get $flags-top) (local.get $flags-bottom))))

 (func $fill-pair-free-list (export "fill-pair-free-list")
   (param $bottom i32)
   (param $top i32)

   (local $next-pair i32)
   (local $pair i32)

   (local.set $pair (local.get $bottom))

   (loop $again
     (local.set $next-pair (i32.add (local.get $pair) (global.get $pair-size)))
     (if (i32.lt_u (local.get $next-pair) (local.get $top))
         (then
          (i32.store (local.get $pair) (local.get $next-pair))
          (local.set $pair (local.get $next-pair))
          (br $again))
       (else
        (i32.store (local.get $pair) (global.get $pair-free-list)))))

   (global.set $pair-free-list (local.get $bottom)))

 (func $expand-pair-storage (export "expand-pair-storage")
   (if (i32.eq (global.get $pairs-top) (global.get $blocks-bottom))
       (then
        (call $begin-relocate-blocks (global.get $page-size))
        (loop $again
          (if (call $is-block-storage-relocating)
              (then
               (call $step-relocate-blocks)
               (br $again))))))

   (call $fill-pair-free-list
         (global.get $pairs-top)
         (global.get $blocks-bottom))

   (global.set $pairs-top (global.get $blocks-bottom)))

 ;;=============================================================================
 ;;
 ;; Kernel Module Initialization
 ;;

 (start $init)
 (func $init
   (call $init-pairs
         (global.get $initial-pairs-bottom)
         (global.get $initial-pairs-top))

   (call $init-refindex)

   (call $init-blocks
         (global.get $initial-blocks-bottom)
         (global.get $initial-blocks-top)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Allocator
 ;;

 (func $alloc-pair (export "alloc-pair")
   (result i32)

   (local $pair-addr i32)

   (if (i32.eq (global.get $pair-free-list) (global.get $null))
       (then
        (call $expand-pair-storage)))

   (local.set $pair-addr (global.get $pair-free-list))

   (global.set $pair-free-list (i32.load (local.get $pair-addr)))

   (local.get $pair-addr))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Functions
 ;;

 (func $make-pair (export "make-pair")
   (param $car i32)
   (param $cdr i32)
   (result i32)

   (local $pair-addr i32)
   (local.set $pair-addr (call $alloc-pair))

   (i32.store (local.get $pair-addr) (local.get $car))
   (i32.store (i32.add (local.get $pair-addr) (global.get $value-size)) (local.get $cdr))

   (i32.or (local.get $pair-addr) (global.get $tag-pair)))

 (func $can-ref (export "can-ref")
   (param $value i32)
   (result i32)

   (local $tag i32)

   (local.set $tag (call $get-value-tag (local.get $value)))

   (i32.or         (i32.eq (local.get $tag) (global.get $tag-block))
                   (i32.or (i32.eq (local.get $tag) (global.get $tag-box))
                           (i32.eq (local.get $tag) (global.get $tag-pair)))))

 (global $ref-list-compact-length (export "ref-list-compact-length" i32 (i32.const 64)))

 (func $add-ref (export "add-ref")
   (param $pair i32)
   (param $value i32)

   (if (call $can-ref (local.get $value))
       (then
        (global.set $ref-list
                    (call $make-pair
                          ;; The pair is the key for index lookup, by putting it
                          ;; in the cdr, it packs the pair as an index entry
                          ;; which can be treated as i64 with the key in the high
                          ;; bits. Hence numeric comparisons on i64 can be used
                          ;; for loading, storing, and comparisons.
                          (call $make-pair (local.get $value) (local.get $pair))
                          (global.get $ref-list)))
        (global.set $ref-list-length (i32.add (global.get $ref-list-length) (i32.const 1)))
        (if (i32.gt_u (global.get $ref-list-length) (global.get $ref-list-compact-length))
            (then
             (call $compact-refindex))))))

 (func $is-pair-reachable (export "is-pair-reachable")
   (param $pair i32)
   (result i32)

   (local $entry-addr i32)
   (local $entry-ref i32)
   (local $idx i32)
   (local $idx-entries-end i32)
   (local $idx-list i32)
   (local $pair-addr i32)
   (local $pair-entry i64)

   (local.set $idx-list (call $get-refindex-generations-list))
   (local.set $pair-addr (call $get-pair-addr (local.get $pair)))
   (local.set $pair-entry (i64.shl (i64.extend_i32_u (local.get $pair-addr))
                                   (i64.const 32)))

   (loop $generations
     (if (i32.ne (local.get $idx-list) (global.get $null))
         (then
          (local.set $idx (call $get-pair-car (local.get $idx-list)))
          (local.set $idx-back (call $get-index-back (local.get $idx)))
          (local.set $entry-addr (call $bisect-left-i64
                                       (call $get-index-front (local.get $idx))
                                       (local.get $idx-back)
                                       (local.get $pair-entry)))

          (loop $search-entries
            (if (i32.lt_u (local.get $entry-addr) (local.get $idx-back))
                (then
                 (if (i32.eq (i32.load (i32.add (local.get $entry-addr)
                                                (global.get $value-size)))
                             (local.get $pair-addr))
                     (then

                      (local.set $entry-ref (i32.load (local.get $entry-addr)))
                      (local.set $entry-addr (i32.add (local.get $entry-addr)
                                                      (global.get $index-entry-size)))

                      (if (i32.ne (local.get $entry-ref) (global.get $deleted-index-entry))
                          (then
                           (if (call $is-marked-reachable (i32.load (local.get $entry-addr)))
                               (then
                                (return (i32.const 1))))))

                      (br $search-entries))))))

          (local.set $idx-list (call $get-pair-cdr (local.get $idx-list)))
          (br $generations))))

   (i32.const 0))

 (func $has-reachable-referrer (export "has-reachable-referrer")
   (param $idx-list i32)
   (param $pair i32)
   (result i32)

   (local $entry-addr i32)
   (local $entry-ref i32)
   (local $idx i32)
   (local $idx-entries-end i32)
   (local $pair-addr i32)
   (local $pair-entry i64)

   (local.set $pair-addr (call $get-pair-addr (local.get $pair)))
   (local.set $pair-entry (i64.shl (i64.extend_i32_u (local.get $pair-addr))
                                   (i64.const 32)))

   (loop $generations
     (if (i32.ne (local.get $idx-list) (global.get $null))
         (then
          (local.set $idx (call $get-pair-car (local.get $idx-list)))
          (if (call $is-index-merging (local.get $idx))
              (then
               (if (call $has-reachable-referrer (local.get $idx) (local.get $pair))
                   (then
                    (return (i32.const 1)))))
            (else
             (local.set $idx-entries-end (call $get-index-entries-end (local.get $idx)))
             (local.set $entry-addr (call $bisect-left-i64
                                          (call $get-index-entries (local.get $idx))
                                          (local.set $idx-entries-end)
                                          (local.get $pair-entry)))

             (loop $search-entries
               (if (i32.lt_u (local.get $entry-addr) (local.get $idx-entries-end))
                   (then
                    (if (i32.eq (i32.load (i32.add (local.get $entry-addr)
                                                   (global.get $value-size)))
                                (local.get $pair-addr))
                        (then

                         (local.set $entry-ref (i32.load (local.get $entry-addr)))
                         (local.set $entry-addr (i32.add (local.get $entry-addr)
                                                         (global.get $index-entry-size)))

                         (if (i32.ne (local.get $entry-ref) (global.get $deleted-index-entry))
                             (then
                              (if (call $is-marked-reachable (i32.load (local.get $entry-addr)))
                                  (then
                                   (return (i32.const 1))))))

                         (br $search-entries))))))))

          (local.set $idx-list (call $get-pair-cdr (local.get $idx-list)))
          (br $generations))))

   (i32.const 0))

 (func $refindex-delete-reference (export "refindex-delete-reference")
   (param $referenced-pair i32)
   (param $referring-pair i32)

   (local $entry-addr i32)
   (local $entry-ref i32)
   (local $idx i32)
   (local $idx-entries-end i32)
   (local $idx-list i32)
   (local $pair-addr i32)
   (local $pair-entry i64)

   (local.set $idx-list (call $get-refindex-generations-list))
   (local.set $pair-addr (call $get-pair-addr (local.get $pair)))
   (local.set $pair-entry (i64.shl (i64.extend_i32_u (local.get $pair-addr))
                                   (i64.const 32)))

   (loop $generations
     (if (i32.ne (local.get $idx-list) (global.get $null))
         (then
          (local.set $idx (call $get-pair-car (local.get $idx-list)))
          (local.set $idx-entries-end (call $get-index-entries-end (local.get $idx)))
          (local.set $entry-addr (call $bisect-left-i64
                                       (call $get-index-entries (local.get $idx))
                                       (local.set $idx-entries-end)
                                       (local.get $pair-entry)))

          (loop $search-entries
            (if (i32.lt_u (local.get $entry-addr) (local.get $idx-entries-end))
                (then
                 (if (i32.eq (i32.load (i32.add (local.get $entry-addr)
                                                (global.get $value-size)))
                             (local.get $pair-addr))
                     (then
                      (i32.store (local.get $entry-addr)
                                 (global.get $deleted-index-entry))

                      (local.set $entry-addr (i32.add (local.get $entry-addr)
                                                      (global.get $index-entry-size)))

                      (br $search-entries))))))

          (local.set $idx-list (call $get-pair-cdr (local.get $idx-list)))
          (br $generations)))))

 (func $refindex-delete-pair-referrers (export "refindex-delete-pair-referrers")
   (param $pair i32)
   (local $entry-addr i32)
   (local $entry-ref i32)
   (local $idx i32)
   (local $idx-entries-end i32)
   (local $idx-list i32)
   (local $pair-addr i32)
   (local $pair-entry i64)

   (local.set $idx-list (call $get-refindex-generations-list))
   (local.set $pair-addr (call $get-pair-addr (local.get $pair)))
   (local.set $pair-entry (i64.shl (i64.extend_i32_u (local.get $pair-addr))
                                   (i64.const 32)))

   (loop $generations
     (if (i32.ne (local.get $idx-list) (global.get $null))
         (then
          (local.set $idx (call $get-pair-car (local.get $idx-list)))
          (local.set $idx-entries-end (call $get-index-entries-end (local.get $idx)))
          (local.set $entry-addr (call $bisect-left-i64
                                       (call $get-index-entries (local.get $idx))
                                       (local.set $idx-entries-end)
                                       (local.get $pair-entry)))

          (loop $search-entries
            (if (i32.lt_u (local.get $entry-addr) (local.get $idx-entries-end))
                (then
                 (if (i32.eq (i32.load (i32.add (local.get $entry-addr)
                                                (global.get $value-size)))
                             (local.get $pair-addr))
                     (then
                      (i32.store (local.get $entry-addr)
                                 (global.get $deleted-index-entry))

                      (local.set $entry-addr (i32.add (local.get $entry-addr)
                                                      (global.get $index-entry-size)))

                      (br $search-entries))))))

          (local.set $idx-list (call $get-pair-cdr (local.get $idx-list)))
          (br $generations)))))

 (func $dealloc-pair (export "dealloc-pair")
   (param $pair i32)

   (call $set-pair-flag (local.get $pair) (i32.const 0))

   (i32.store (call $get-pair-car-addr (local.get $pair))
              (global.get $pair-free-list))

   (if (call $is-pair-block-owner (local.get $pair))
       (then
        (call $dealloc-block (call $get-pair-cdr (local.get $pair)))))

   (global.set $pair-free-list (local.get $pair)))

 (func $dealloc-list-pairs (export "dealloc-list-pairs")
   (param $pair i32)

   (local $car i32)
   (local $cdr i32)

   (local.set $car (call $get-pair-car (local.get $pair)))
   (local.set $cdr (call $get-pair-cdr (local.get $pair)))

   (if (call $is-pair-value (local.get $car))
       (then
        (call $dealloc-list-pairs (local.get $car))))

   (if (call $is-pair-value (local.get $cdr))
       (then
        (call $dealloc-list-pairs (local.get $cdr))))

   (call $dealloc-pair (local.get $pair)))

 (func $alloc-block-value (export "make-block-value")
   (param $block-type i32)
   (param $length i32)
   (result i32)

   (local $pair-addr i32)
   (local.set $pair-addr (call $alloc-pair))

   (call $set-pair-car (local.get $pair-addr) (local.get $block-type))
   (call $set-pair-cdr
         (local.get $pair-addr)
         (call $alloc-block (local.get $pair-addr) (local.get $length)))

   (i32.or (local.get $pair-addr) (global.get $tag-block)))

 ;;  (func $make-block-value (export "make-block-value")
 ;;    (param $block-type i32)
 ;;    (param $block i32)
 ;;    (result i32)

 ;; )

 (func $dealloc-block-value (export "dealloc-block-value")
   (param $block-value i32)

   (local $block i32)

   (local.set $block (call $get-block-value-block (local.get $block-value)))

   (if (i32.ne (local.get $block) (global.get $null))
       (then
        (call $dealloc-block (local.get $block))))
   (call $dealloc-pair (local.get $block-value)))

 (func $alloc-vector (export "alloc-vector")
   (param $length i32)
   (result i32)

   (call $alloc-block-value
         (global.get $block-value-type-vector)
         (local.get $length)))

 ;; (func $make-vector (export "make-vector")
 ;;   (param $length i32)
 ;;   (param $fill-value i32)
 ;;   (result i32)

 ;;   (local $vector i32)
 ;;   (call $make-block-value )
 ;;   nop)

 (func $dealloc-vector (export "dealloc-vector")
   (param $vector i32)
   (call $dealloc-block-value (local.get $vector)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Ref Index
 ;;
 ;; A ref index provides a way to determine which pairs refer to a given pair.
 ;; Ref indexes are vectors which contain the number of 64-bit entries in the
 ;; first value, and an index used during mereges in the second. The third and
 ;; subsequent values for 64-bit entries where the low 32 bits are the address
 ;; of the referencing pair, and the upper 32 bits are the address of the
 ;; referenced pair. These entries are sorted to allow binary search for lookup.
 ;; The referenced pair is used in lookup, and so its address is in the high
 ;; bits to allow numeric comparisons in searching and merging.

 (func $get-index-length (export "get-index-length")
   (param $index i32)
   (result i32)
   (i32.load (call $get-vector-elements (local.get $index))))

 (func $get-index-cursor (export "get-index-cursor")
   (param $index i32)
   (result i32)
   (i32.load (i32.add (call $get-vector-elements (local.get $index))
                      (global.get $value-size))))

 (func $get-index-entries (export "get-index-entries")
   (param $index i32)
   (result i32)
   (i32.add (call $get-vector-elements (local.get $index))
            (global.get $index-entry-size)))

 (func $get-index-entries-end (export "get-index-entries-end")
   (param $index i32)
   (result i32)
   (call $get-vector-elements-end (local.get $index)))

 (func $get-index-front (export "get-index-front")
   (param $index i32)
   (result i32)
   (local $cursor i32)
   (local $elements i32)
   (local.set $elements (call $get-vector-elements (local.get $index)))
   (local.set $cursor (i32.add (local.get $elements)
                               (global.get $value-size)))

   (i32.add (local.get $elements)
            (if (result i32) (i32.ge_s (local.get $cursor) (i32.const 0))
              (then
               (local.get $cursor))
              (else
               (global.get $index-entry-size)))))

 (func $get-index-back (export "get-index-back")
   (param $index i32)
   (result i32)
   (local $cursor i32)
   (local.set $cursor (call $get-index-cursor (local.get $index)))

   (if (result i32) (i32.ge_s (local.get $cursor) (i32.const 0))
     (then
        (call $get-vector-elements-end (local.get $index)))
     (else
      (i32.add (call $get-vector-elements-end (local.get $index))
               (local.get $cursor)))))

 (func $set-index-length (export "set-index-length")
   (param $index i32)
   (param $length i32)
   (i32.store (call $get-vector-elements (local.get $index))
              (local.get $length)))

 (func $set-index-front (export "set-index-front")
   (param $index i32)
   (param $cursor i32)
   (local $elements i32)
   (local.set $elements (call $get-vector-elements (local.get $index)))
   (i32.store (i32.add (local.get $elements)
                       (global.get $value-size))
              (i32.sub (local.get $cursor) (local.get $elements))))

 (func $set-index-back (export "set-index-back")
   (param $index i32)
   (param $cursor i32)
   (local $elements i32)
   (local.set $elements )
   (i32.store (i32.add (call $get-vector-elements (local.get $index))
                       (global.get $value-size))
              (i32.sub (call $get-vector-elements-end (local.get $index))
                       (local.get $cursor))))

 (func $decr-index-length (export "decr-index-length")
   (param $index i32)
   (local $length-addr i32)
   (local.set $length-addr (call $get-vector-elements (local.get $index)))

   (i32.store (local.get $length-addr)
              (i32.sub (i32.load (local.get $length-addr))
                       (i32.const 1))))

 (func $alloc-index (export "alloc-index")
   (param $length i32)
   (result i32)

   (local $index i32)

   (local.set $index (call $alloc-vector
                           (i32.add (local.get $length)
                                    (global.get $index-entry-length))))

   (call $set-index-length (local.get $index) (local.get $length))
   (call $set-index-cursor (local.get $index) (i32.const 0))
   (local.get $index))

 (func $dealloc-index (export "dealloc-index")
   (param $index i32)
   (call $dealloc-vector (local.get $index)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Generational Ref Index
 ;;
 ;; Updating an index becomes increasingly costly as the index grows. The ref
 ;; index is used to find separated pairs which can be deallocated, and
 ;; typically these are some of the most recently allocated pairs. To take
 ;; advantage of this, we keep a sequence of ref indexes, each older and larger
 ;; than the previous.
 ;;
 ;; References are first kept in a linked list to allow allocation to be fast.
 ;; Once the ref list reaches a threshold size, it is converted into a ref index
 ;; and inserted at the front of the generations list.  If the new ref index is
 ;; has more than n/log2(n) entries, where n is the number of entries in the
 ;; next older ref index, then the two are merged.
 ;;
 ;; Deleting an entry leaves it in place, but sets the referencing pair address
 ;; to $null.  Deleted entries are dropped during mergers.

 ;; Each entry is 8 bytes => 0x2000 bytes == 8 KB is 1024 entries

 (global $default-refindex-merge-step-length
         (export "default-refindex-merge-step-length")
         i32 (i32.const 0x100))

 (func $get-refindex-generations-list (export "get-refindex-generations-list")
   (result i32)
   (call $get-pair-car
         (i32.add (global.get $pairs-bottom)
                  (global.get $refindex-generations-list-pair))))

 (func $set-refindex-generations-list (export "set-refindex-generations-list")
   (param $pair i32)
   (call $set-pair-car
         (i32.add (global.get $pairs-bottom)
                  (global.get $refindex-generations-list-pair))
         (local.get $pair)))

 (func $is-index-merging (export "is-index-merging")
   (param $idx i32)
   (result i32)
   (i32.eqz (call $is-vector-value (local.get $idx))))

 (func $compact-refindex (export "compact-refindex")
   (local $head i32)
   (local $i i32)
   (local $j i32)
   (local $next i32)

   (local.set $i (call $make-ref-list-index))
   (call $dealloc-ref-list)

   (if (i32.ne (local.get $i) (global.get $null))
       (then
        (call $set-refindex-generations-list
              (call $make-pair (local.get $i)
                    (call $get-refindex-generations-list)))))

   (local.set $head (call $get-refindex-generations-list))

   (loop
     (local.set $next (call $get-pair-cdr (local.get $head)))
     (if (i32.ne (local.get $next) (global.get $null))
         (then
          (local.set $i (call $get-pair-car (local.get $head)))
          (local.set $j (call $get-pair-car (local.get $next)))

          (if (call $is-index-merging (local.get $j))
              (then
               (local.set $j (call $step-merge-refindex-generations
                                   (local.get $j)
                                   (global.get $default-refindex-merge-step-length)))
               (call $set-pair-car (local.get $next) (local.get $j))))

          (if (i32.and (i32.and (i32.eqz (call $is-index-merging (local.get $i)))
                                (i32.eqz (call $is-index-merging (local.get $j))))
                       (i32.gt_u (call $get-vector-length (local.get $i))
                                 (call $calc-refindex-minimum-merge-threshold (local.get $j))))
              (then
               (call $set-pair-car
                     (local.get $head)
                     (call $begin-merge-refindex-generations
                           (local.get $i)
                           (local.get $j)))

               (call $set-pair-cdr
                     (local.get $head)
                     (call $get-pair-cdr (local.get $next)))

               (call $dealloc-pair (local.get $next)))
            (else
             (local.set $head (local.get $next))))))))

 (func $make-ref-list-index (export "make-ref-list-index")
   ;; converts ref-list into a sorted array of index entries, then
   (result i32)

   (local $entry-addr i32)
   (local $head i32)
   (local $idx i32)
   (local $next i32)

   (if (result i32) (i32.eq (global.get $ref-list) (global.get $null))
     (then
      (global.get $null))

     (else
      (local.set $idx (call $alloc-index
                            (i32.mul (global.get $ref-list-length)
                                     (global.get $index-entry-length))))

      (local.set $head (global.get $ref-list))

      (local.set $entry-addr (call $get-index-entries (local.get $idx)))

      (loop $again

        (i64.store (local.get $entry-addr)
                   (i64.load (call $get-pair-addr (call $get-pair-car (local.get $head)))))

        (local.set $next (call $get-pair-cdr (local.get $head)))

        (if (i32.ne (local.get $next) (global.get $null))
            (then
             (local.set $head (local.get $next))
             (local.set $entry-addr (i32.add (local.get $entry-addr)
                                             (global.get $index-entry-size)))
             (br $again))))

      (call $sort-index-entries (local.get $idx))
      (local.get $idx))))

 (func $sort-index-entries (export "sort-index-entries")
   (param $idx i32)

   (local $entries i32)

   (local.set $entries (call $get-index-entries (local.get $idx)))

   (call $hoare-quicksort-i64
         (local.get $entries)
         (local.get $entries)
         (call $get-index-entries-end (local.get $idx))))

 (func $begin-merge-refindex-generations (export "begin-merge-refindex-generations")
   (param $a i32)
   (param $b i32)
   (result i32)

   (local $c i32)
   (local $i i32)

   (local.set $c (call $alloc-index
                       (i32.add (call $get-index-length (local.get $a))
                                (call $get-index-length (local.get $b)))))

   (local.set $i (call $make-pair
                       (local.get $a)
                       (call $make-pair
                             (local.get $b)
                             (call $make-pair
                                   (local.get $c)
                                   (global.get $null)))))

   (call $step-merge-refindex-generations
         (local.get $i)
         (global.get $default-refindex-merge-step-length)))

 (func $calc-refindex-minimum-merge-threshold (export "calc-refindex-minimum-merge-threshold")
   ;; calculates a rough estimate of length idx / log2 (length idx)
   (param $idx i32)
   (result i32)

   (local $n i32)

   (local.set $n (call $get-index-length (local.get $idx)))

   (i32.div_u (local.get $n)
              (i32.sub (i32.const 32) (i32.clz (local.get $n)))))

 ;; The referencing value of an index entry for a deleted relationship. No pair
 ;; will ever be at address 0, so this is an unambiguous value. It also enables
 ;; the conditionals in the copy loops of $step-merge-refindex-generations to be
 ;; simpler than if this were $null.
 (global $deleted-index-entry (export "deleted-index-entry") i32 (i32.const 0))

 ;; Used below as the entry value of an index that has exhausted its elements during
 ;; the merge. This value ensures that the comparison with the other index's values
 ;; always allows the value to be copied.
 (global $highest-index-entry-value (export "highest-index-entry-value") 164 (i64.const -1))

 (func $step-merge-refindex-generations (export "step-merge-refindex-generations")
   (param $i i32)
   (param $step-length i32)
   (result i32)

   (local $a i32)
   (local $b i32)
   (local $c i32)
   (local $a-end i32)
   (local $b-end i32)
   (local $c-end i32)
   (local $c-step-end i32)
   (local $entry-a i64)
   (local $entry-b i64)
   (local $cursor-a i32)
   (local $cursor-b i32)
   (local $cursor-c i32)
   (local $x i32)

   (local.set $x (local.get $i))

   (local.set $a (call $get-pair-car (local.get $x)))
   (local.set $x (call $get-pair-cdr (local.get $x)))

   (local.set $b (call $get-pair-car (local.get $x)))
   (local.set $x (call $get-pair-cdr (local.get $x)))

   (local.set $c (call $get-pair-car (local.get $x)))

   (local.set $cursor-a (call $get-index-front (local.get $a)))
   (local.set $cursor-b (call $get-index-front (local.get $b)))
   (local.set $cursor-c (call $get-index-back (local.get $c)))

   (local.set $a-end (call $get-index-entries-end (local.get $a)))
   (local.set $b-end (call $get-index-entries-end (local.get $b)))
   (local.set $c-end (call $get-index-entries-end (local.get $c)))

   (local.set $c-step-end (i32.add (local.get $cursor-c)
                                   (i32.mul (local.get $step-length)
                                            (global.get $index-entry-size))))

   (if (i32.lt_u (local.get $c-step-end) (local.get $c-end))
       (then
        (local.set $c-end (local.get $c-step-end))))

   (loop $merge
     (if (i32.and (i32.ne (local.get $cursor-a) (local.get $a-end))
                  (i32.ne (local.get $cursor-c) (local.get $c-end)))
         (then
          (loop $copy-a
            (local.set $entry-a (i64.load (local.get $cursor-a)))
            (if (i64.lt_u (local.get $entry-a) (local.get $entry-b))
                (then
                 (if (i32.ne (i32.wrap_i64 (local.get $entry-a))
                             (global.get $deleted-index-entry))
                     (then
                      (i64.store (local.get $cursor-c) (local.get $entry-a))
                      (local.set $cursor-c (i32.add (local.get $cursor-c) (i32.const 8)))))
                 (local.set $cursor-a (i32.add (local.get $cursor-a) (i32.const 8)))
                 (if (i32.ne (local.get $cursor-a) (local.get $a-end))
                     (then
                      (br $copy-a))
                   (else
                    (local.set $entry-a (global.get $highest-index-entry-value)))))))))

     (if (i32.and (i32.ne (local.get $cursor-b) (local.get $b-end))
                  (i32.ne (local.get $cursor-c) (local.get $c-end)))
         (then
          (loop $copy-b
            (local.set $entry-b (i64.load (local.get $cursor-b)))
            (if (i64.lt_u (local.get $entry-b) (local.get $entry-a))
                (then
                 (if (i32.ne (i32.wrap_i64 (local.get $entry-b))
                             (global.get $deleted-index-entry))
                     (then
                      (i64.store (local.get $cursor-c) (local.get $entry-b))
                      (local.set $cursor-c (i32.add (local.get $cursor-c) (i32.const 8)))))
                 (local.set $cursor-b (i32.add (local.get $cursor-b) (i32.const 8)))
                 (if (i32.ne (local.get $cursor-b) (local.get $b-end))
                     (then
                      (br $copy-b))
                   (else
                    (local.set $entry-b (global.get $highest-index-entry-value)))))))))

     (if (i32.and (i32.or (i32.ne (local.get $cursor-a) (local.get $a-end))
                          (i32.ne (local.get $cursor-b) (local.get $b-end)))
                  (i32.ne (local.get $cursor-c) (local.get $c-end)))
         (then
          (br $merge))))

   (call $set-index-front (local.get $a) (local.get $cursor-a))
   (call $set-index-front (local.get $b) (local.get $cursor-b))
   (call $set-index-back  (local.get $c) (local.get $cursor-c))

   (if (result i32) (i32.and (i32.eq (local.get $cursor-a) (local.get $a-end))
                             (i32.eq (local.get $cursor-b) (local.get $b-end)))
     (then
      (call $dealloc-index (local.get $a))
      (call $dealloc-index (local.get $b))
      (call $dealloc-list-pairs (local.get $i))

      (local.get $c))

     (else
      (local.get $i))))

 (func $dealloc-ref-list (export "dealloc-ref-list")

   (local $head-addr i32)
   (local $next i32)
   (local $next-addr i32)
   (local $ref-list-addr i32)

   (if (i32.ne (global.get $ref-list) (global.get $null))
       (then
        (local.set $ref-list-addr (call $get-pair-car-addr (global.get $ref-list)))
        (local.set $head-addr (local.get $ref-list-addr))

        (loop $again
          (local.set $next (i32.load (i32.add (local.get $head-addr)
                                              (global.get $value-size))))

          (if (i32.eq (local.get $next) (global.get $null))
              (then
               (i32.store (call $get-pair-car-addr (i32.load (local.get $head-addr)))
                          (global.get $pair-free-list)))
            (else
             (local.set $next-addr (call $get-pair-car-addr (local.get $next)))
             (i32.store (call $get-pair-car-addr (i32.load (local.get $head-addr)))
                        (local.get $next-addr))
             (local.set $head-addr (local.get $next-addr))
             (br $again))))

        (global.set $pair-free-list (local.get $ref-list-addr))
        (global.set $ref-list (global.get $null))
        (global.set $ref-list-length (i32.const 0)))))

 (func $release (export "release")
   (param $pair i32)
   (param $value i32)

   (if (call $can-ref (local.get $value))
       (then
        (call $gc-release (local.get $pair) (local.get $value)))))

 (func $gc-release (export "gc-release")
   (param $pair i32)
   (param $value i32)

   (if (i32.eq (global.get $gc-state) (global.get $gc-state-separating))
       (then
        (trace-value-mark-separated (local.get $value)))
     (else
      (global.set $sep-list
                  (call $make-pair
                        (local.get $value)
                        (global.get $sep-list)))))
   (call $gc-step))

 (func $gc-step (export "gc-step")
   (if (i32.eq (global.get $gc-state) (global.get $gc-state-separating))
       (then
        (if (i32.gt_u (global.get $separated-pair-count)
                      (call $calc-gc-mark-threshold))
            (then
             (call $gc-prepare-marking-phase)))))

   (if (i32.eq (global.get $gc-state) (global.get $gc-state-marking))
       (then
        (call $gc-mark-step)
        (if (i32.eqz (global.get $uncertain-group-count))
            (then
             (call $gc-prepare-sweeping-phase)))))

   (if (i32.eq (global.get $gc-state) (global.get $gc-state-sweeping))
       (then
        (call $gc-sweep-step)
        (if (i32.eqz (global.get $stale-group-count))
            (then
             (call $gc-prepare-separating-phase))))))

 (func $gc-prepare-marking-phase (export "gc-prepare-marking-phasee")
   (global.set $uncertain-group-count (call $count-uncertain-groups))
   (global.set $gc-state (global.get $gc-state-marking)))

 (func $gc-prepare-sweeping-phase (export "gc-prepare-sweeping-phasee")
   (global.set $stale-group-count (call $count-stale-groups))
   (global.set $gc-state (global.get $gc-state-sweeping)))

 (func $gc-prepare-separating-phase (export "gc-prepare-separating-phasee")
   (local $head i32)

   (global.set $gc-state (global.get $gc-state-separating))

   (local.set $head (global.get $sep-list))
   (loop $again
     (if (i32.ne (local.get $head) (global.get $null))
         (then
          (call $trace-value-mark-separated (call $get-pair-car (local.get $head)))
          (call $dealloc-pair (local.get $head))
          (local.set $head (call $get-pair-cdr (local.get $head)))
          (br $again))))

   (global.set $sep-list (global.get $null)))

 (func $gc-mark-step (export "gc-mark-step")
   ;; get next uncertain group
   ;; for all separated pairs
   ;;   if has known reachable referrer, trace reachable
   ;;   otherwise, mark group as stale
   )

 (func $gc-sweep-step (export "gc-sweep-step")
   )



;;   (call $compact-refindex)
;;   (call $trace-value-mark-separated (local.get $pair))
;;   (call $trace-value-dealloc-unreachable (local.get $pair))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Interface Functions
 ;;

 (func $cons (export "cons")
   (param $car i32)
   (param $cdr i32)
   (result i32)

   (local $pair i32)
   (local.set $pair (call $make-pair (local.get $car) (local.get $cdr)))

   (call $add-ref (local.get $pair) (local.get $car))
   (call $add-ref (local.get $pair) (local.get $cdr))

   (local.get $pair))

 (func $car (export "car")
   (param $pair i32)
   (result i32)
   (i32.load (i32.xor (local.get $pair) (global.get $tag-pair))))

 (func $cdr (export "cdr")
   (param $pair i32)
   (result i32)
   (i32.load (i32.add
              (i32.xor (local.get $pair) (global.get $tag-pair))
              (global.get $value-size))))

 (func $set-car (export "set-car")
   (param $pair i32)
   (param $value i32)

   (call $release (local.get $pair) (call $car (local.get $pair)))

   (i32.store (call $get-pair-car-addr (local.get $pair))
              (local.get $value))

   (call $add-ref (local.get $pair) (local.get $value)))

 (func $set-cdr (export "set-cdr")
   (param $pair i32)
   (param $value i32)

   (call $release (local.get $pair) (call $cdr (local.get $pair)))

   (i32.store (call $get-pair-cdr-addr (local.get $pair))
              (local.get $value))

   (call $add-ref (local.get $pair) (local.get $value)))

 ;;=============================================================================
 ;;
 ;; Blocks
 ;;

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Accessors
 ;;

 (func $get-blocks-bottom (export "get-blocks-bottom")
   (result i32)
   (i32.load (global.get $blocks-bottom)))

 (func $get-blocks-top (export "get-blocks-top")
   (result i32)
   (i32.load (global.get $blocks-top)))

 (func $get-block-count (export "get-block-count")
   (result i32)
   (i32.load (global.get $block-count)))

 (func $get-blocks-free-list (export "get-blocks-free-list")
   (result i32)
   ;; The first block in the storage area is always the head of the free list.
   (i32.load (global.get $blocks-bottom)))

 (func $get-blocks-relocation-offset (export "get-blocks-relocation-offset")
   (result i32)
   (i32.load (global.get $blocks-relocation-offset)))

 (func $get-blocks-relocation-end (export "get-blocks-relocation-end")
   (result i32)
   (i32.load (global.get $blocks-relocation-end)))

 (func $get-blocks-current-relocation (export "get-blocks-current-relocation")
   (result i32)
   (i32.load (global.get $blocks-current-relocation)))

 (func $get-blocks-free-area (export "get-blocks-free-area")
   (result i32)
   (i32.load (global.get $blocks-free-area)))

 (func $set-blocks-bottom (export "set-blocks-bottom")
   (param $bottom i32)
   (i32.store (global.get $blocks-bottom) (local.get $bottom)))

 (func $set-blocks-top (export "set-blocks-top")
   (param $top i32)
   (i32.store (global.get $blocks-top) (local.get $top)))

 (func $set-block-count (export "set-block-count")
   (param $block-count i32)
   (i32.store (global.get $block-count) (local.get $block-count)))

 (func $set-blocks-relocation-offset (export "set-blocks-relocation-offset")
   (param $relocation-offset i32)
   (i32.store (global.get $blocks-relocation-offset)
              (local.get $relocation-offset)))

 (func $set-blocks-relocation-end (export "set-blocks-relocation-end")
   (param $relocation-end i32)
   (i32.store (global.get $blocks-relocation-end)
              (local.get $relocation-end)))

 (func $set-blocks-current-relocation (export "set-blocks-current-relocation")
   (param $current-relocation i32)
   (i32.store (global.get $blocks-current-relocation)
              (local.get $current-relocation)))

 (func $set-blocks-free-area (export "set-blocks-free-area")
   (param $free-area i32)
   (i32.store (global.get $blocks-free-area) (local.get $free-area)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Utilities
 ;;

 (func $get-blocks-initial-block (export "get-blocks-initial-block")
   (result i32)
   (call $get-blocks-free-list))

 (func $is-blocks-free-list-empty (export "is-blocks-free-list-empty")
   (result i32)
   (call $is-last-free-block (call $get-blocks-free-list)))

 (func $is-block-storage-relocating (export "is-block-storage-relocating")
   (result i32)
   (i32.ne (call $get-blocks-current-relocation) (global.get $null)))

 (func $decr-block-count (export "decr-block-count")
   (call $set-block-count (i32.sub (call $get-block-count)
                                   (i32.const 1))))

 (func $incr-block-count (export "incr-block-count")
   (call $set-block-count (i32.add (call $get-block-count)
                                   (i32.const 1))))


 ;;
 ;;
 ;;

 ;; Block storage area page header

 ;; Count of 64Ki pages (contiguous) in the block storage area

 ;; Address of the first free block in the free-list.

 ;; When relocating, this is the offset from the current block storage area to
 ;; the target area. This will be a positive multiple of 64Ki during
 ;; relocations, zero otherwise.

 ;; When relocating, this is the address of the lowest block address that needs
 ;; to be relocated.

 ;; When relocating, this is the address of the highest block address that needs
 ;; to be relocated.

 ;; The initial blocklist and initial free-list consist of a single free block of
 ;; length -1.

 ;; Initializes the free block at the given address

 ;; Blockstore structure

 ;; Constructors

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Initialization
 ;;

 (func $init-blocks (export "init-blocks")
   (param $bottom i32)
   (param $top i32)

   (local $free-block i32)

   (global.set $blocks-bottom (local.get $bottom))
   (global.set $blocks-top (local.get $top))

   (global.set $block-count (i32.const 1))
   (global.set $blocks-relocation-offset (i32.const 0))
   (global.set $blocks-current-relocation (global.get $null))
   (global.set $blocks-relocation-end (global.get $null))

   (local.set $free-block (call $get-blocks-free-list))
   (call $make-free-block
         (local.get $free-block)
         (i32.const 1)
         (global.get $null))

   (global.set $blocks-free-area (call $get-next-block (local.get $free-block))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Relocation
 ;;

 (func $begin-relocate-blocks (export "begin-relocate-blocks")
   (param $offset i32)

   (local $free-area i32)

   (local.set $free-area (call $get-blocks-free-area))

   (call $set-blocks-current-relocation (call $get-blocks-bottom))
   (call $set-blocks-relocation-end (local.get $free-area))
   (call $set-blocks-relocation-offset (local.get $offset))

   (call $set-blocks-free-area (i32.add (local.get $free-area)
                                        (local.get $offset))))

 (func $end-relocate-blocks (export "end-relocate-blocks")
   (call $set-blocks-current-relocation (global.get $null))
   (call $set-blocks-relocation-end (global.get $null))
   (call $set-blocks-relocation-offset (i32.const 0)))

 (func $relocate-free-block (export "relocate-free-block")
   (param $free-block i32)

   (local $next-free-block i32)
   (local $offset i32)

   (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
   (local.set $offset (call $get-blocks-relocation-offset))

   (if (i32.ne (local.get $next-free-block) (global.get $null))
       (then
        (local.set $next-free-block (i32.add (local.get $next-free-block)
                                             (local.get $offset)))))

   (call $make-free-block
         (i32.add (local.get $free-block) (local.get $offset))
         (call $get-block-length (local.get $free-block))
         (local.get $next-free-block)))

 (func $relocate-block (export "relocate-block")
   (param $block i32)

   (local $offset i32)
   (local $relocated-block i32)

   (local.set $offset (call $get-blocks-relocation-offset))
   (local.set $relocated-block (i32.add (local.get $block) (local.get $offset)))

   (call $set-block-value-block
         (call $get-block-owner (local.get $block))
         (local.get $relocated-block))

   (memory.copy (local.get $relocated-block)
                (local.get $block)
                (call $get-block-size (local.get $block))))

 (func $step-relocate-blocks (export "step-relocate-blocks")

   (local $block i32)
   (local $block-ref i32)

   (local.set $block (call $get-blocks-current-relocation))

   (if (call $is-free-block (local.get $block))
       (then
        (call $relocate-free-block (local.get $block)))
     (else
      (call $relocate-block (local.get $block))))

   (local.set $block (call $get-next-block (local.get $block)))

   (if (i32.eq (local.get $block) (call $get-blocks-relocation-end))
       (then
        (call $end-relocate-blocks))
     (else
      (call $set-blocks-current-relocation (local.get $block)))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Compaction
 ;;

 (func $step-blocks-compact (export "step-blocks-compact")

   (local $block-moved i32)
   (local $block-orig i32)
   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-free-length i32)
   (local $next-next-free-block i32)

   (if (i32.and (i32.eqz (call $is-block-storage-relocating))
                (i32.eqz (call $is-blocks-free-list-empty)))
       (then

        (local.set $free-block (call $get-blocks-free-list))
        (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
        (local.set $next-free-length (call $get-block-length (local.get $next-free-block)))
        (local.set $next-next-free-block (call $get-next-free-block (local.get $next-free-block)))

        (local.set $block-orig (call $get-next-block (local.get $next-free-block)))
        (local.set $block-moved (local.get $next-free-block))

        (memory.copy (local.get $block-moved)
                     (local.get $block-orig)
                     (call $get-block-size (local.get $block-orig)))

        (local.set $next-free-block (call $get-next-block (local.get $block-moved)))

        (call $make-free-block
              (local.get $next-free-block)
              (local.get $next-free-length)
              (local.get $next-next-free-block))

        (call $set-next-free-block
              (local.get $free-block)
              (local.get $next-free-block))

        (call $compact-block-free-list))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Allocation
 ;;

 (func $can-split-free-block (export "can-split-free-block")
   (param $block i32)
   (param $split-length i32)
   (result i32)

   (local $length i32)
   (local.set $length (call $get-block-length (local.get $block)))

   (i32.and
    ;; is this block a free block?
    (call $is-free-block (local.get $block))

    ;; and is there enough room in the current block for the number of values
    ;; requested, a block header for the new block, and at least one more for
    ;; the free-list link address?
    (i32.gt_u (local.get $length)
              (i32.add (local.get $split-length)
                       (global.get $block-header-length)))))

 (func $split-free-block (export "split-free-block")
   (param $block i32)
   (param $split-length i32)
   (result i32)

   (local $length i32)
   (local $new-block i32)
   (local $new-block-length i32)
   (local $next-free-block i32)

   (local.set $length (call $get-block-length (local.get $block)))

   (if (result i32) (i32.eqz (call $can-split-free-block
                                   (local.get $block)
                                   (local.get $split-length)))
     (then (i32.const 0))
     (else
      (local.set $new-block
                 (i32.add (local.get $block)
                          (call $calc-block-size (local.get $split-length))))

      (local.set $new-block-length
                 (i32.sub
                  (i32.sub (local.get $length)
                           (local.get $split-length))
                  (global.get $block-header-length)))

      (local.set $next-free-block (call $get-next-free-block (local.get $block)))

      (call $make-free-block
            (local.get $block)
            (local.get $split-length)
            (local.get $new-block))

      (call $make-free-block
            (local.get $new-block)
            (local.get $new-block-length)
            (local.get $next-free-block))

      (call $incr-block-count)
      (i32.const 1))))

 (func $alloc-exact-free-list-block (export "alloc-exact-free-list-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $new-block i32)

   (local.set $free-block (call $get-blocks-free-list))
   (local.set $new-block (global.get $null))

   (loop $again
     (if (i32.eqz (call $is-last-free-block (local.get $free-block)))
         (then
          (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
          (if (i32.eq (call $get-block-length (local.get $next-free-block))
                      (local.get $length))
              (then
               (call $set-next-free-block
                     (local.get $free-block)
                     (call $get-next-free-block (local.get $next-free-block)))
               (local.set $new-block (local.get $next-free-block))
               (call $set-block-owner (local.get $new-block) (local.get $owner)))
            (else
             (if (i32.eqz (call $is-last-free-block (local.get $next-free-block)))
                 (then
                  (local.set $free-block (local.get $next-free-block))
                  (br $again))))))))

   (local.get $new-block))

 (func $alloc-split-free-list-block (export "alloc-split-free-list-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $new-block i32)

   (local.set $free-block (call $get-blocks-free-list))
   (local.set $new-block (global.get $null))

   (loop $again
     (if (i32.eqz (call $is-last-free-block (local.get $free-block)))
         (then
          (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
          (if (call $split-free-block
                    (local.get $next-free-block)
                    (local.get $length))
              (then
               (call $set-next-free-block
                     (local.get $free-block)
                     (call $get-next-free-block (local.get $next-free-block)))

               (local.set $new-block (local.get $next-free-block))
               (call $set-block-owner (local.get $new-block) (local.get $owner)))
            (else
             (if (i32.eqz (call $is-last-free-block (local.get $next-free-block)))
                 (then
                  (local.set $free-block (local.get $next-free-block))
                  (br $again))))))))

   (local.get $new-block))

 (func $ensure-blocks-alloc-top (export "ensure-blocks-alloc-top")
   (param $alloc-top i32)

   (local $memory-size i32)
   (local $size i32)
   (local $size-required i32)
   (local $top i32)

   (local.set $top (call $get-blocks-top))

   (if (i32.gt_u (local.get $alloc-top) (local.get $top))
       (then
        (local.set $size (memory.size))
        (local.set $size-required (i32.add (i32.shr_u (i32.sub (local.get $alloc-top)
                                                               (i32.const 1))
                                                      (global.get $page-size-bits))
                                           (i32.const 1)))

        (if (i32.gt_u (local.get $size-required) (local.get $size))
            (then
             (drop (memory.grow (i32.sub (local.get $size-required) (local.get $size))))))

        (call $set-blocks-top (i32.shl (local.get $size-required)
                                       (global.get $page-size-bits))))))

 (func $alloc-end-block (export "alloc-end-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-free-list-end-block i32)
   (local $new-block i32)

   (local.set $new-block (call $get-blocks-free-area))

   (call $ensure-blocks-alloc-top
         (i32.add (local.get $new-block)
                  (call $calc-block-size (local.get $length))))

   (call $set-block-owner
         (local.get $new-block)
         (local.get $owner))

   (call $set-block-length
         (local.get $new-block)
         (local.get $length))

   (call $set-blocks-free-area (call $get-next-block (local.get $new-block)))

   (call $incr-block-count)

   (local.get $new-block))

 (func $alloc-block (export "alloc-block")
   (param $owner i32)
   (param $n i32)
   (result i32)

   (local $new-block i32)

   (if (i32.eqz (local.get $n))
       (then (return (global.get $null))))

   (if (i32.eqz (call $is-block-storage-relocating))
       (then
        (local.set $new-block (call $alloc-exact-free-list-block
                                    (local.get $owner)
                                    (local.get $n)))

        (if (i32.ne (local.get $new-block) (global.get $null))
            (then
             (return (local.get $new-block))))

        (local.set $new-block (call $alloc-split-free-list-block
                                    (local.get $owner)
                                    (local.get $n)))

        (if (i32.ne (local.get $new-block) (global.get $null))
            (then
             (return (local.get $new-block))))))

   (call $alloc-end-block
         (local.get $owner)
         (local.get $n)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Deallocation
 ;;

 (func $add-free-block (export "add-free-block")
   (param $block i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $offset i32)

   (local.set $free-block (call $get-blocks-free-list))

   (loop $again
     (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
     (if (i32.and
          (i32.ne (local.get $next-free-block) (global.get $null))
          (i32.lt_u (local.get $next-free-block)
                    (local.get $block)))
         (then
          (local.set $free-block (local.get $next-free-block))
          (br $again))

       (else
        (call $set-next-free-block (local.get $free-block) (local.get $block))

        (call $make-free-block
              (local.get $block)
              (call $get-block-length (local.get $block))
              (local.get $next-free-block))

        (if (call $is-block-storage-relocating)
            (then
             (call $relocate-free-block (local.get $free-block))
             (call $relocate-free-block (local.get $block))))))))

 (func $join-adjacent-free-blocks (export "join-adjacent-free-blocks")
   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-block (call $get-next-free-block (call $get-blocks-free-list)))

   (loop $again
     (if (i32.eqz (call $is-last-free-block (local.get $free-block)))
         (then
          (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
          (if (i32.eq (local.get $next-free-block)
                      (call $get-next-block (local.get $free-block)))
              (then
               (call $make-free-block
                     (local.get $free-block)
                     (i32.add (call $get-block-length (local.get $free-block))
                              (i32.add (call $get-block-length (local.get $next-free-block))
                                       (global.get $block-header-length)))
                     (call $get-next-free-block (local.get $next-free-block)))
               (call $decr-block-count))
            (else
             (local.set $free-block (local.get $next-free-block))))
          (br $again)))))

 (func $drop-free-block-at-end (export "drop-free-block-at-end")

   (local $free-area i32)
   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-area (call $get-blocks-free-area))
   (local.set $free-block (call $get-blocks-free-list))

   (loop $again
     (if (i32.eqz (call $is-last-free-block (local.get $free-block)))
         (then
          (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
          (if (i32.eq (call $get-next-block (local.get $next-free-block))
                      (local.get $free-area))
              (then
               (call $set-next-free-block (local.get $free-block) (global.get $null))
               (call $set-blocks-free-area (local.get $next-free-block))
               (call $decr-block-count))
            (else
             (local.set $free-block (local.get $next-free-block))
             (br $again)))))))

 (func $compact-block-free-list (export "compact-block-free-list")

   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-block (call $get-blocks-free-list))

   (if (i32.eqz (call $is-blocks-free-list-empty))
       (then
        (call $join-adjacent-free-blocks)
        (call $drop-free-block-at-end))))

 (func $dealloc-block (export "dealloc-block")
   (param $block i32)

   (call $add-free-block (local.get $block))

   (if (i32.eqz (call $is-block-storage-relocating))
       (then
        (call $compact-block-free-list))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Tracing
 ;;

 (func $mark-pair-reachable (export "mark-pair-reachable")
   (param $pair i32)
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-reachable)))

 (func $mark-pair-dirty (export "mark-pair-dirty")
   (param $pair i32)
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-separated)))

 (func $mark-pair-scanned (export "mark-pair-scanned")
   (param $pair i32)
   (call $clear-pair-flag (local.get $pair) (global.get $pair-flag-separated)))

 (func $mark-block-reachable (export "mark-block-reachable")
   (param $block i32)

   (local $addr i32)
   (local $current-pair i32)
   (local $length i32)
   (local $end-pair i32)

   (call $replace-pair-flags (local.get $block) (global.get $pair-flag-reachable))

   ;; clear tag bits to convert block to a pair address
   (local.set $addr (i32.and (local.get $block) (i32.xor (global.get $value-tag-mask) (i32.const -1))))

   ;; the first value of the pair is the address of the storage array
   (local.set $current-pair (i32.load (local.get $addr)))

   ;; the second value is its length in values
   (local.set $length (i32.load (i32.add (local.get $addr) (global.get $value-size))))

   ;; calculate the address of the final pair of the storage array
   (local.set $end-pair
              (i32.add
               (local.get $current-pair)
               (i32.mul
                (global.get $pair-size)
                (i32.shr_u (local.get $length) (i32.const 1)))))

   ;; decrement the current pair by one pair length also mark the
   ;; storage array link pair. If this pair is not marked as reachable
   ;; at the end of the collection cycle, then the storage for the corresponding
   ;; array will be released.
   (local.set $current-pair (i32.sub (local.get $current-pair) (global.get $pair-size)))

   ;; loop through the pairs in the storage array, marking each
   (loop $again
     (call $mark-pair-reachable (local.get $current-pair))
     (if (i32.lt_u (local.get $current-pair) (local.get $end-pair))
         (then
          (local.set $current-pair (i32.add (local.get $current-pair) (global.get $pair-size)))
          (br $again)))))






 )
