(module

 (import "memory" "main" (memory 1))

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
 (global $blocks-free-area          (export "blocks-free-area")          (mut i32) (i32.const 0xffffffff))

 ;; Block structure

 (global $block-owner           (export "block-owner")           i32 (i32.const 0x0000))
 (global $block-length          (export "block-length")          i32 (i32.const 0x0004))

 ;; Sizes and lengths

 (global $block-header-length    (export "block-header-length")    i32 (i32.const 2))
 (global $block-header-size      (export "block-header-size")      i32 (i32.const 0x0008))

 ;; Refindex

 (global $index-entry-size      (export "index-entry-size")      i32 (i32.const 8))
 (global $index-entry-length    (export "index-entry-length")    i32 (i32.const 2))

 ;;
 (global $root-block-free-list            (export "root-block-free-list")            i32 (i32.const 0x00000000))
 (global $root-pair-flags                 (export "root-pair-flags")                 i32 (i32.const 0x00000008))
 (global $root-stale-pair-group-flags     (export "root-stale-pair-group-flags")     i32 (i32.const 0x00000010))
 (global $root-uncertain-pair-group-flags (export "root-uncertain-pair-group-flags") i32 (i32.const 0x00000018))

 ;; (global $root-z (export "root-z") i32 (i32.const 0))

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

 (func $make-free-block (export "make-free-block")
   (param $block i32)
   (param $length i32)

   (call $set-block-owner     (local.get $block) (global.get $null))
   (call $set-block-length    (local.get $block) (local.get $length)))

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
         (global.get $initial-blocks-top))

   ;; depends on both pairs and blocks
   (call $init-pair-flags))

 (func $init-pair-flags (export "init-pair-flags")

   (call $init-bytearray-value
         (global.get $root-pair-flags)
         (global.get $initial-pair-flags-size))

   (call $init-bytearray-value
         (global.get $root-stale-pair-group-flags)
         (global.get $initial-pair-group-flags-size))

   (call $init-bytearray-value
         (global.get $root-uncertain-pair-group-flags)
         (global.get $initial-pair-group-flags-size))

   (call $mark-pair-reachable (global.get $root-pair-flags))
   (call $mark-pair-reachable (global.get $root-stale-pair-group-flags))
   (call $mark-pair-reachable (global.get $root-uncertain-pair-group-flags)))

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

   (global.set $block-count (i32.const 0))
   (call $set-pair-car (global $root-block-free-list) (global.get $null))

   (global.set $blocks-free-area (local.get $bottom)))

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


 (func $dealloc-pair (export "dealloc-pair")
   (param $pair i32)

   (call $set-pair-flag (local.get $pair) (i32.const 0))

   (if (call $is-pair-block-owner (local.get $pair))
       (then
        (call $dealloc-block (call $get-pair-cdr (local.get $pair)))))

   (i32.store (call $get-pair-car-addr (local.get $pair))
              (global.get $pair-free-list))

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

 (func $alloc-block-value (export "alloc-block-value")
   (param $block-type i32)
   (param $length i32)
   (result i32)

   (local $pair-addr i32)
   (local.set $pair-addr (call $alloc-pair))

   (call $init-block-value
         (local.get $pair-addr)
         (local.get $block-type)
         (local.get $length)))

 (func $init-block-value (export "init-block-value")
   (param $pair-addr $i32)
   (param $block-type i32)
   (param $length i32)

   (call $set-pair-car (local.get $pair-addr) (local.get $block-type))
   (call $set-pair-cdr
         (local.get $pair-addr)
         (call $alloc-block (local.get $pair-addr) (local.get $length)))

   (i32.or (local.get $pair-addr) (global.get $tag-block)))

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

 (func $get-block-free-list (export "get-block-free-list")
   (result i32)
   (call $get-pair-car (global.get $root-block-free-list)))

 (func $get-block-free-list-addr (export "get-block-free-list-addr")
   (result i32)
   (call $get-pair-car-addr(global.get $root-block-free-list)))

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

 (func $set-blocks-free-area (export "set-blocks-free-area")
   (param $free-area i32)
   (i32.store (global.get $blocks-free-area) (local.get $free-area)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Utilities
 ;;

 (func $get-blocks-initial-block (export "get-blocks-initial-block")
   (result i32)
   (call $get-blocks-bottom))

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
 ;; Blocks Compaction
 ;;

 (func $step-blocks-compact (export "step-blocks-compact")

   (local $block i32)
   (local $block-dest i32)
   (local $head i32)
   (local $free-block i32)
   (local $free-block-length i32)

   (local.set $head (call $get-block-free-list))
   (if (i32.ne (local.get $head) (global.get $null))
       (then
        (local.set $free-block (call $get-pair-car (local.get $head)))
        (local.set $free-length (call $get-block-length (local.get $free-block)))
        (local.set $block (call $get-next-block (local.get $free-block)))
        (local.set $block-dest (local.get $free-block))

        (memory.copy (local.get $block-dest)
                     (local.get $block)
                     (call $get-block-size (local.get $block)))

        (local.set $free-block (call $get-next-block (local.get $block-dest)))

        (call $make-free-block
              (local.get $free-block)
              (local.get $free-length))

        (call $set-pair-car
              (local.get $next)
              (local.get $free-block))

        (call $compact-block-free-list))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Allocation
 ;;

 (func $alloc-exact-free-list-block (export "alloc-exact-free-list-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $head i32)
   (local $head-addr i32)
   (local $new-block i32)

   (local.set $head-addr (call $get-block-free-list-addr))
   (local.set $new-block (global.get $null))

   (loop $again
     (local.set $head (i32.load (local.get $head-addr)))
     (if (i32.ne (local.get $head) (global.get $null))
         (then
          (local.set $free-block (call $get-pair-car (local.get $head)))
          (if (i32.eq (call $get-block-length (local.get $free-block))
                      (local.get $length))
              (then
               (i32.store (local.get $head-addr) (call $get-pair-cdr (local.get $head)))
               (local.set $new-block (local.get $free-block))
               (call $set-block-owner (local.get $new-block) (local.get $owner)))
            (else
             (local.set $head-addr (call $get-pair-cdr-addr (local.get $head)))
             (br $again))))))

   (local.get $new-block))

 (func $alloc-split-free-list-block (export "alloc-split-free-list-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $head i32)
   (local $head-addr i32)
   (local $new-block i32)

   (local.set $head (call $get-block-free-list))
   (local.set $new-block (global.get $null))

   (loop $again
     (if (i32.ne (local.get $head) (global.get $null))
         (then
          (local.set $free-block (call $get-pair-car (local.get $head)))
          (if (call $can-split-free-block (local.get $free-block) (local.get $length))
              (then
               (call $set-pair-car
                     (local.get $head)
                     (call $split-free-block (local.get $free-block) (local.get $length)))

               (local.set $new-block (local.get $free-block))
               (call $set-block-owner (local.get $new-block) (local.get $owner)))
            (else
             (local.set $head (call $get-pair-cdr (local.get $head)))
             (br $again))))))

   (local.get $new-block))

 (func $can-split-free-block (export "can-split-free-block")
   (param $free-block i32)
   (param $split-length i32)
   (result i32)

   (local $length i32)
   (local.set $length (call $get-block-length (local.get $free-block)))

   (i32.and
    ;; and is there enough room in the current block for the number of values
    ;; requested, a block header for the new block
    (i32.ge_u (local.get $length)
              (i32.add (local.get $split-length)
                       (global.get $block-header-length)))))

 (func $split-free-block (export "split-free-block")
   (param $free-block i32)
   (param $split-length i32)
   (result i32)

   (local $new-block i32)
   (local $new-block-length i32)

   (local.set $new-block-length
              (i32.sub
               (i32.sub (call $get-block-length (local.get $free-block))
                        (local.get $split-length))
               (global.get $block-header-length)))

   (call $set-block-length (local.get $free-block) (local.get $split-length))
   (local.set $new-block (call $get-next-block (local.get $free-block)))

   (call $make-free-block
         (local.get $new-block)
         (local.get $new-block-length))

   (call $incr-block-count)
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
        (return (local.get $new-block))))

   (call $alloc-end-block
         (local.get $owner)
         (local.get $n)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blocks Deallocation
 ;;

 (func $add-free-block (export "add-free-block")
   (param $block i32)

   (local $head i32)
   (local $head-addr i32)

   (local.set $head-addr (call $get-block-free-list-addr))

   (loop $again
     (local.set $head (i32.load (local.get $head-addr)))
     (if (i32.ne (local.get $head) (global.get $null))
         (then
          (if (i32.gt_u (local.get $block) (call $get-pair-car (local.get $head)))
            (then
             (local.set $head-addr (call $get-pair-cdr-addr (local.get $head)))
             (br $again))))))

   (i32.store (local.get $head-addr)
              (call $make-pair
                    (local.get $block)
                    (local.get $head))))

 (func $join-adjacent-free-blocks (export "join-adjacent-free-blocks")
   (local $block i32)
   (local $head i32)
   (local $next i32)
   (local $next-block i32)

   (local.set $head (call $get-block-free-list))

   (if (i32.ne (local.get $head) (global.get $null))
       (then
        (local.set $block (call $get-pair-car (local.get $head)))
        (loop $again
          (local.set $next (call $get-pair-cdr (local.get $head)))
          (if (i32.ne (local.get $next) (global.get $null))
              (then
               (local.set $next-block (call $get-pair-car (local.get $next)))
               (if (i32.eq (local.get $next-block)
                           (call $get-next-block (local.get $block)))
                   (then
                    (call $set-block-length
                          (local.get $block)
                          (i32.add (call $get-block-length (local.get $block))
                                   (i32.add (call $get-block-length (local.get $next-block))
                                            (global.get $block-header-length))))
                    (call $decr-block-count)
                    (call $set-pair-cdr (local.get $head) (call $get-pair-cdr (local.get $next)))
                    (call $dealloc-pair (local.get $next))
                    (br $again))

                 (else
                  (local.set $head (local.get $next))
                  (local.set $block (local.get $next-block))))))))))

 (func $drop-free-block-at-end (export "drop-free-block-at-end")

   (local $block i32)
   (local $head i32)
   (local $head-addr i32)
   (local $next i32)
   (local $next-addr i32)

   (local.set $head-addr (call $get-block-free-list-addr))
   (local.set $head (i32.load (local.get $head-addr)))

   (if (i32.ne (local.get $head) (global.get $null))
       (then
        (loop $again
          (local.set $next-addr (call $get-pair-cdr-addr (local.get $head)))
          (local.set $next (i32.load (local.get $next-addr)))
          (if (i32.ne (local.get $next) (global.get $null))
              (then
               (local.set $head (local.get $next))
               (local.set $head-addr (local.get $next-addr))
               (br $again))
            (else
             (local.set $block (call $get-pair-car (local.get $head)))
             (if (i32.eq (call $get-next-block (local.get $block))
                         (call $get-blocks-free-area))
                 (then
                  (call $set-blocks-free-area (local.get $block))
                  (i32.store (local.get $head-addr) (global.get $null))
                  (call $dealloc-pair (local.get $head))
                  (call $decr-block-count)))))))))

 (func $compact-block-free-list (export "compact-block-free-list")
   (call $join-adjacent-free-blocks)
   (call $drop-free-block-at-end))

 (func $dealloc-block (export "dealloc-block")
   (param $block i32)

   (call $add-free-block (local.get $block))
   (call $compact-block-free-list))









 )
