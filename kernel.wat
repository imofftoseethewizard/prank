(module

 ;; Pairs
 ;;
 ;; Pairs are the fundamental data type, from which values of all other types
 ;; are referenced.

 ;; Blockstore, pairs, refindex.

 (memory (export "memory") 5)

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


 (global $initial-pairs-bottom (export "initial-pairs-bottom") i32 (i32.const 0x00004000))
 (global $initial-pairs-top    (export "initial-pairs-top")    i32 (i32.const 0x00010000))

 (global $pairs-bottom                  (export "pairs-bottom")                  (mut i32) (i32.const 0xffffffff))
 (global $pairs-top                     (export "pairs-top")                     (mut i32) (i32.const 0xffffffff))
 (global $pair-count                    (export "pair-count")                    (mut i32) (i32.const 0x00000000))
 (global $pair-free-list                (export "pair-free-list")                (mut i32) (i32.const 0xffffffff))
 (global $blockstore-bottom             (export "blockstore-bottom")             (mut i32) (i32.const 0xffffffff))
 (global $blockstore-top                (export "blockstore-top")                (mut i32) (i32.const 0xffffffff))
 (global $blockstore-block-count        (export "blockstore-block-count")        (mut i32) (i32.const 0x00000000))
 (global $blockstore-relocation-offset  (export "blockstore-relocation-offset")  (mut i32) (i32.const 0x00000000))
 (global $blockstore-relocation-end     (export "blockstore-relocation-end")     (mut i32) (i32.const 0xffffffff))
 (global $blockstore-current-relocation (export "blockstore-current-relocation") (mut i32) (i32.const 0xffffffff))
 (global $blockstore-free-area          (export "blockstore-free-area")          (mut i32) (i32.const 0xffffffff))

 ;; Block structure

 (global $block-owner           (export "block-owner")           i32 (i32.const 0x0000))
 (global $block-length          (export "block-length")          i32 (i32.const 0x0004))
 (global $free-block-next-block (export "free-block-next-block") i32 (i32.const 0x0008))

 ;; Sizes and lengths

 (global $block-header-length    (export "block-header-length")    i32 (i32.const 2))
 (global $block-header-size      (export "block-header-size")      i32 (i32.const 0x0008))

 (global $pair-addr-mask      (export "pair-addr-mask")      i32 (i32.const 0xfffffff8))

 (global $pair-flag-reachable (export "pair-flag-reachable") i32 (i32.const 1))
 (global $pair-flag-uncertain   (export "pair-flag-uncertain")   i32 (i32.const 2))
 (global $pair-flags-mask     (export "pair-flags-mask")     i32 (i32.const 0x00000003))

 (global $pair-flag-reachable-i64-group i64 (i64.const 0x5555555555555555))
 (global $pair-flag-uncertain-i64-group   i64 (i64.const 0xaaaaaaaaaaaaaaaa))

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

 ;;-----------------------------------------------------------------------------
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

 (global $eof   (export "#eof-object") i32 (i32.const 0xeee00fff))
 (global $false (export "#false")      i32 (i32.const 0x0000001f))
 (global $null  (export "#null")       i32 (i32.const 0xffffffff))
 (global $true  (export "#true")       i32 (i32.const 0x0000003f))

 ;; Refindex

 (global $refindex-entry-size      (export "refindex-entry-size")      i32 (i32.const 8))
 (global $refindex-entry-addr-mask (export "refindex-entry-addr-mask") i32 (i32.const 0xfffffff8))

 ;;=============================================================================
 ;;
 ;; Values
 ;;

 (func $value-tag (export "value-tag")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $value-tag-mask)))

 (func $value-data (export "value-data")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $data-mask)))

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

 ;;=============================================================================
 ;;
 ;; Block values
 ;;

 (global $block-value-type  (export "block-value-type")  i32 (i32.const 0x0000))
 (global $block-value-block (export "block-value-block") i32 (i32.const 0x0004))

 (global $block-value-type-bytearray (export "block-value-type-bytearray") i32 (i32.const 0))
 (global $block-value-type-number    (export "block-value-type-number")    i32 (i32.const 1))
 (global $block-value-type-string    (export "block-value-type-string")    i32 (i32.const 2))
 (global $block-value-type-vector    (export "block-value-type-vector")    i32 (i32.const 3))

 (func $get-block-value-type (export "set-block-value-type")
   (param $block-value i32)
   (i32.load (i32.add (local.get $block-value)
                      (global.get $block-value-type))))

 (func $get-block-value-block (export "set-block-value-block")
   (param $block-value i32)
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
 ;; Box values
 ;;

 (global $box-value-type  (export "box-value-type")  i32 (i32.const 0x0000))
 (global $box-value-value (export "box-value-value") i32 (i32.const 0x0004))

 (global $box-value-type-weakref (export "box-value-type-weakref") i32 (i32.const 0))

 (func $get-box-value-type (export "set-box-value-type")
   (param $box-value i32)
   (i32.load (i32.add (local.get $box-value)
                      (global.get $box-value-type))))

 (func $get-box-value-value (export "set-box-value-value")
   (param $box-value i32)
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

   (i32.store (global.get $refindex-cut) (global.get $null))

   ;; (i32.store (global.get $refindex-lower-bottom)
   ;;            (...))
   ;; (i32.store (global.get $refindex-lower-top)
   ;;            (...))
   ;; (i32.store (global.get $refindex-upper-bottom)
   ;;            (...))
   ;; (i32.store (global.get $refindex-upper-top)
   ;;            (...))
   )

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

 (func $bisect-refindex-lower-bound (export "bisect-refindex-lower-bound")
   (param $pair i32)
   (param $index i32)
   (param $length i32)

   (local $key i32)
   (local $hi i32)
   (local $lo i32)
   (local $mid i32)

   (local.set $lo (local.get $index))
   (local.set $hi (i32.mul (local.get $length)
                           (global.get $entry-size)))

   (local.set $key (call $get-value-data (local.get $pair)))

   (loop $again
     (local.set $mid (i32.and (i32.add (i32.shr_u (local.get $lo))
                                       (i32.shr_u (local.get $hi)))
                              (global.get $refindex-entry-addr-mask)))  ;; TODO
     (if (i32.ge_u (local.get $key) (i32.load (local.get $mid)))
         (then
          (local.set $lo (local.get $mid)))
       (else
        (local.set $hi (local.get $mid))))
     (if (i32.lt_u (local.get $lo) (local.get $hi))
         (then
          (br $again))))

   (local.get $lo))

 (func $bisect-refindex-upper-bound (export "bisect-refindex-upper-bound")
   (param $pair i32)

   (local $key i32)
   (local $hi i32)
   (local $lo i32)
   (local $mid i32)

   (local.set $key (call $get-value-data (local.get $pair)))

   (if (i32.lt_u (local.get $key) (call $get-refindex-cut)) ;; TODO
       (then
        (local.set $lo (call $get-refindex-lower-bottom)) ;; TODO
        (local.set $hi (call $get-refindex-lower-top)))
     (else
      (local.set $lo (call $get-refindex-upper-bottom))
      (local.set $hi (call $get-refindex-upper-top))))

   (loop $again
     (local.set $mid (i32.and (i32.add (i32.shr_u (local.get $lo))
                                       (i32.shr_u (local.get $hi)))
                              (global.get $refindex-entry-addr-mask)))  ;; TODO
     (if (i32.gt_u (local.get $key) (i32.load (local.get $mid)))
         (then
          (local.set $lo (local.get $mid)))
       (else
        (local.set $hi (local.get $mid))))
     (if (i32.lt_u (local.get $lo) (local.get $hi))
         (then
          (br $again))))

   (local.get $lo))

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

 (func $get-pair-addr (export "get-pair-addr")
   (param $pair i32)
   (result i32)
   (call $get-value-data (local.get $pair)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Flags
 ;;

 (func $get-pair-flags-location (export "get-pair-flags-location")
   (param $pair i32)
   (result i32 i32)

   (i32.shr_u (local.get $pair)
              (global.get $pair-flag-addr-shift))

   (i32.shr_u (i32.and (local.get $pair)
                       (global.get $pair-flag-idx-mask))
              (global.get $pair-flag-idx-shift)))

 ;; get-pair-flags takes the address of a pair and returns the flag from
 ;; the containing page's 2KB memory management bitmap

 (func $get-pair-flags (export "get-pair-flags")
   (param $pair i32)
   (result i32)

   (local $addr i32)
   (local $shift-count i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $shift-count)
   (local.set $addr)

   (i32.and
    (global.get $pair-flags-mask)
    (i32.shr_u
     (i32.load8_u (local.get $addr))
     (local.get $shift-count))))

 (func $set-pair-flags (export "set-pair-flags")
   (param $pair i32)
   (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $shift-count)
   (local.set $addr)

   (local.set $flag (i32.and (local.get $flag) (global.get $pair-flags-mask)))

   (i32.store8
    (local.get $addr)
    (i32.or
     (i32.and
      (i32.load8_u (local.get $addr))
      (i32.xor
       (i32.const -1)
       (i32.shl
        (global.get $pair-flags-mask)
        (local.get $shift-count))))
     (i32.shl
      (i32.and
       (local.get $flag)
       (global.get $pair-flags-mask))
      (local.get $shift-count)))))

 (func $set-pair-flag (export "set-pair-flag")
   (param $pair i32)
   (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $shift-count)
   (local.set $addr)

   (i32.store8
    (local.get $addr)
    (i32.or
     (i32.load8_u (local.get $addr))
     (i32.shl
      (i32.and
       (local.get $flag)
       (global.get $pair-flags-mask))
      (local.get $shift-count)))))

 (func $clear-pair-flag (export "clear-pair-flag")
   (param $pair i32)
   (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $shift-count)
   (local.set $addr)

   (i32.store8
    (local.get $addr)
    (i32.and
     (i32.load8_u (local.get $addr))
     (i32.xor
      (i32.const -1)
      (i32.shl
       (i32.and
        (local.get $flag)
        (global.get $pair-flags-mask))
       (local.get $shift-count))))))

 (func $get-group-ready-pair-map (export "get-group-ready-pair-map")
   (param $flags i64)
   (result i64)

   (i64.and ;; see $get-group-free-pair-map below, uses or
    (i64.shr_u (i64.and (global.get $pair-flag-uncertain-i64-group)
                        (local.get $flags))
               (i64.const 1))
    (i64.and (global.get $pair-flag-reachable-i64-group)
             (local.get $flags))))

 (func $get-group-free-pair-map (export "get-group-free-pair-map")
   (param $flags i64)
   (result i64)

   (i64.xor (global.get $pair-flag-reachable-i64-group)
            (i64.or ;; see $get-group-ready-pair-map above, uses and
             (i64.shr_u (i64.and (global.get $pair-flag-uncertain-i64-group)
                                 (local.get $flags))
                        (i64.const 1))
             (i64.and (global.get $pair-flag-reachable-i64-group)
                      (local.get $flags)))))

 (func $get-flag-group-pair-offset (export "get-flag-group-pair-offset")
   (param $group i32)
   (result i32)

   (i32.and (global.get $pair-page-offset-mask)
            (i32.shl (local.get $group)
                     (global.get $pair-flag-addr-shift))))

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

 (func $clear-pair-flags (export "clear-pair-flags")
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

 (func $mark-pair-uncertain (export "mark-pair-uncertain")
   (param $value i32)

   (call $set-pair-flags
         (local.get $value)
         (global.get $pair-flag-uncertain)))

 (func $trace-value-dealloc-unreachable (export "trace-value-dealloc-unreachable")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $value-tag (local.get $value)))

   (if (i32.eq (call $get-pair-flags) (global.get $pair-flag-uncertain))
       (then
        (if (i32.eq (local.get $tag) (global.get $tag-pair))
            (then
             (if (call $is-marked-uncertain (local.get $value))
                 (then
                  (if (call $is-pair-reachable (local.get $value))
                      (then
                       (call $trace-value-mark-reachable (local.get $value)))
                    (else
                     (call $dealloc-pair (local.get $value))
                     (call $trace-value-dealloc-unreachable (call $get-pair-car (local.get $value)))
                     (call $trace-value-dealloc-unreachable (call $get-pair-cdr (local.get $value))))))))))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-block))
          (then
           (if (call $is-marked-uncertain (local.get $value))
               (then
                (if (call $is-pair-reachable (local.get $value))
                    (then
                     (call $trace-block-mark-reachable (local.get $value)))
                  (else
                   (call $dealloc-block-value (local.get $value))
                   (call $trace-block-dealloc-unreachable (local.get $value)))))))))))

 (func $trace-value-mark-reachable (export "trace-value-mark-reachable")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $value-tag (local.get $value)))

   (if (i32.eq (local.get $tag) (global.get $tag-pair))
       (then
        (if (call $is-marked-uncertain (local.get $value))
            (then
             (call $mark-pair-reachable (local.get $value))
             (call $trace-value-mark-reachable (call $get-pair-car (local.get $pair)))
             (call $trace-value-mark-reachable (call $get-pair-cdr (local.get $pair))))))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-block))
          (then
           (if (call $is-marked-uncertain (local.get $value))
               (then
                (call $mark-pair-reachable (local.get $value))
                (call $trace-block-mark-reachable (local.get $value)))))))))

 (func $trace-value-mark-uncertain (export "trace-value-mark-uncertain")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $value-tag (local.get $value)))

   (if (i32.eq (local.get $tag) (global.get $tag-pair))
       (then
        (if (call $is-marked-reachable (local.get $value))
            (then
             (call $mark-pair-uncertain (local.get $value))
             (call $trace-value-mark-uncertain (call $get-pair-car (local.get $pair)))
             (call $trace-value-mark-uncertain (call $get-pair-cdr (local.get $pair))))))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-block))
          (then
           (if (call $is-marked-reachable (local.get $value))
               (then
                (call $mark-pair-uncertain (local.get $value))
                (call $trace-block-mark-uncertain (local.get $value)))))))))

 (func $trace-block-dealloc-unreachable (export "trace-block-dealloc-unreachable")
   (param $block-value i32)

   (local $block i32)
   (local $element i32)
   (local $end-element i32)
   (local $value i32)

   (local.set $block (call $get-block-value-block (local.get $block-value)))

   (if (i32.and (i32.eq (call $get-block-value-type (local.get $block-value))
                        (global.get $block-value-vector))
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

 (func $trace-block-mark-uncertain (export "trace-block-mark-uncertain")
   (param $block-value i32)

   (local $block i32)
   (local $element i32)
   (local $end-element i32)
   (local $value i32)

   (local.set $block (call $get-block-value-block (local.get $block-value)))

   (if (i32.and (i32.eq (call $get-block-value-type (local.get $block-value))
                        (global.get $block-value-vector))
                (i32.ne (local.get $block) (global.get $null)))
       (then
        (local.set $end-element (call $get-block-elements-end (local.get $block)))
        (loop $again
          (if (i32.lt_u (local.get $element) (local.get $end-element))
              (then
               (call $trace-value-mark-uncertain (i32.load (local.get $element)))
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
                        (global.get $block-value-vector))
                (i32.ne (local.get $block) (global.get $null)))
       (then
        (local.set $end-element (call $get-block-elements-end (local.get $block)))
        (loop $again
          (if (i32.lt_u (local.get $element) (local.get $end-element))
              (then
               (call $trace-value-mark-reachable (i32.load (local.get $element)))
               (local.set $element (call $get-next-element (local.get $element)))
               (br $again)))))))


 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Initialization
 ;;

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
          (i32.store $pair (local.get $next-pair))
          (local.set $pair (local.get $next-pair))
          (br $again))
       (else
        (i32.store $pair (global.get $pair-free-list)))))

   (global.set $pair-free-list (local.get $bottom)))

 (func $expand-pair-storage (export "expand-pair-storage")
   (if (i32.eq (global.get $pairs-top) (global.get $blockstore-bottom))
       (then
        (call $relocate-blockstore (global.get $page-size))))

   (call $fill-pair-free-list
         (global.get $pairs-top)
         (global.get $blockstore-bottom))

   (global.set $pairs-top (local.get $blockstore-bottom)))

 (func $init-pairs (export "init-pairs")

   (global.set $pairs-bottom (local.get $bottom))
   (global.set $pairs-top (local.get $top))
   (global.set $pairs-pair-count (i32.const 0))
   (global.set $pair-free-list (global.get $null))

   (call $clear-pair-flags (local.get $bottom) (local.get $top))

   (call $fill-pair-free-list (local.get $bottom) (local.get $top)))

 (start $init)
 (func $init
   (call $init-pairs
         (global.get $initial-pairs-bottom)
         (global.get $initial-pairs-top))

   (call $init-refindex
         (global.get $initial-refindex-bottom)
         (global.get $initial-refindex-top))

   (call $init-blockstore
         (global.get $initial-blockstore-bottom)
         (global.get $initial-blockstore-top)))

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

   (i32.or         (i32.eq (local.get $tag) (global.get $block))
           (i32.or (i32.eq (local.get $tag) (global.get $box))
                   (i32.eq (local.get $tag) (global.get $pair)))))

 (func $add-ref (export "add-ref")
   (param $pair i32)
   (param $value i32)

   (if (call $can-ref (local.get $value))
       (then
        (global.set $ref-count (i32.add (global.get $ref-count) (i32.const 1)))
        (global.set $ref-list
                    (call $make-pair
                          ;; The pair is the key for index lookup, by putting it
                          ;; in the cdr, it packs the pair as an index entry
                          ;; which can be treated as i64 with the key in the high
                          ;; bits. Hence numeric comparisons on i64 can be used
                          ;; for loading, storing, and comparisons.
                          (call $make-pair (local.get $value) (local.get $pair))
                          (global.get $ref-list))))))

 (func $is-pair-reachable (export "is-pair-reachable")
   (param $pair i32)
   (result i32)
   nop)

 (func $dealloc-pair (export "dealloc-pair")
   (param $pair i32)
   (result i32)

   ;; remove from refindex
   (call $clear-pair-flags (local.get $pair))

   (i32.store (call $get-pair-addr (local.get $pair))
              (global.get $pair-free-list))

   (global.set $pair-free-list (local.get $pair)))

 (func $compact-refindex (export "compact-refindex")
   ;; reflist -> sorted vector
   ;; for i_n , i_n+1,
   ;;   if i_n not merging, i_n+1 not merging, and len(i_n) > len(i_n+1)/log2(len_i_1), then
   ;;     start merge i_n, i_n+1
   ;; for the least index merging pair,
   ;;   process a chunk
   ;;
   ;; a merging index pair is a list of 3 vectors and three scalars: i_n, i_n+1, and j, and
   ;; m_i, m_i+1, m_j of the index into each of the vectors. Searches proceeed normally until
   ;; j is finished, at which point it becomes the new i_n and i_n+2 is renumber to i_n+1, etc.
   ())

 (func $dealloc-ref-list (export "dealloc-ref-list")
   (param $head-addr i32)
   (param $next-addr i32)

   (if (i32.ne (global.get $ref-list) (global.get $null))
       (then
        (local.set $ref-list-addr (call $get-pair-addr (global.get $ref-list)))
        (local.set $head-addr (local.get $ref-list-addr))

        (loop $again
          (local.set $next (i32.load (i32.add (local.get $head-addr)
                                              (global.get $value-size))))

          (if (i32.eq (local.get $next) (global.get $null))
              (then
               (i32.store (call $get-pair-addr (i32.load $head-addr))
                          (global.get $pair-free-list)))
            (else
             (local.set $next-addr (call $get-pair-addr (local.get $next)))
             (i32.store (call $get-pair-addr (i32.load $head-addr))
                        (local.get $next-addr))
             (local.set $head-addr (local.get $next-addr))
             (br $again))))

        (global.set $pair-free-list (local.get $ref-list-addr))
        (global.set $ref-list (global.get $null))
        (global.set $ref-list-length (i32.const 0)))))

 (func $sort-index-entries (export "sort-index-entries")
   ())

 (func $make-ref-list-index (export "make-ref-list-index")
   ;; converts ref-list into a sorted array of index entries, then
   (result i32)

   (local $entry i64)
   (local $head-addr i32)
   (local $idx i32)
   (local $next i32)

   (if (result i32) (i32.eq (global.get $ref-list) (global.get $null))
     (then
      (global.get $null))

     (else
      (local.set $idx (call $alloc-block
                            (i32.mul (global.get $ref-list-count)
                                     (global.get $index-entry-length))))

      (local.set $head-addr (call $get-pair-addr (global.get $ref-list)))

      (local.set $entry (i64.extend_i32_u (call $get-block-elements (local.get $idx))))

      (loop $again

        (i64.store (local.get $entry)
                   (i64.load (i64.extend_i32_u (call $get-pair-addr
                                                     (local.get $head-addr)))))

        (local.set $next (i32.load (i32.add (local.get $head-addr)
                                            (global.get $value-size))))

        (if (i32.ne (local.get $next) (global.get $null))
            (then
             (local.set $head-addr (call $get-pair-addr (local.get $next)))
             (local.set $entry (i64.add (local.get $entry)
                                        (global.get $refindex-entry-size)))
             (br $again))))

        (call $sort-index-entries $idx)
        (local.get $idx))))

 (func $release (export "release")
   (param $pair i32)
   (param $value i32)

   (call $compact-refindex)
   (call $trace-value-mark-uncertain (local.get $pair))
   (call $trace-value-dealloc-unreachable (local.get $pair)))

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

   (i32.store (call $get-car-address (local.get $pair))
              (local.get $value))

   (call $add-ref (local.get $pair) (local.get $value)))

 (func $set-cdr (export "set-cdr")
   (param $pair i32)
   (param $value i32)

   (call $release (local.get $pair) (call $cdr (local.get $pair)))

   (i32.store (call $get-cdr-address (local.get $pair))
              (local.get $value))

   (call $add-ref (local.get $pair) (local.get $value)))

 ;;=============================================================================
 ;;
 ;; Blockstore
 ;;

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Accessors
 ;;

 (func $get-blockstore-bottom (export "get-blockstore-bottom")
   (result i32)
   (i32.load (global.get $blockstore-bottom)))

 (func $get-blockstore-top (export "get-blockstore-top")
   (result i32)
   (i32.load (global.get $blockstore-top)))

 (func $get-blockstore-block-count (export "get-blockstore-block-count")
   (result i32)
   (i32.load (global.get $blockstore-block-count)))

 (func $get-blockstore-free-list (export "get-blockstore-free-list")
   (result i32)
   ;; The first block in the storage area is always the head of the free list.
   (i32.load (global.get $blockstore-bottom)))

 (func $get-blockstore-relocation-offset (export "get-blockstore-relocation-offset")
   (result i32)
   (i32.load (global.get $blockstore-relocation-offset)))

 (func $get-blockstore-relocation-end (export "get-blockstore-relocation-end")
   (result i32)
   (i32.load (global.get $blockstore-relocation-end)))

 (func $get-blockstore-current-relocation (export "get-blockstore-current-relocation")
   (result i32)
   (i32.load (global.get $blockstore-current-relocation)))

 (func $get-blockstore-free-area (export "get-blockstore-free-area")
   (result i32)
   (i32.load (global.get $blockstore-free-area)))

 (func $set-blockstore-bottom (export "set-blockstore-bottom")
   (param $bottom i32)
   (i32.store (global.get $blockstore-bottomm) (local.get $bottom)))

 (func $set-blockstore-top (export "set-blockstore-top")
   (param $top i32)
   (i32.store (global.get $blockstore-top) (local.get $top)))

 (func $set-blockstore-block-count (export "set-blockstore-block-count")
   (param $block-count i32)
   (i32.store (global.get $blockstore-block-count) (local.get $block-count)))

 (func $set-blockstore-relocation-offset (export "set-blockstore-relocation-offset")
   (param $relocation-offset i32)
   (i32.store (global.get $blockstore-relocation-offset)
              (local.get $relocation-offset)))

 (func $set-blockstore-relocation-end (export "set-blockstore-relocation-end")
   (param $relocation-end i32)
   (i32.store (global.get $blockstore-relocation-end)
              (local.get $relocation-end)))

 (func $set-blockstore-current-relocation (export "set-blockstore-current-relocation")
   (param $current-relocation i32)
   (i32.store (global.get $blockstore-current-relocation)
              (local.get $current-relocation)))

 (func $set-blockstore-free-area (export "set-blockstore-free-area")
   (param $free-area i32)
   (i32.store (global.get $blockstore-free-area) (local.get $free-area)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Utilities
 ;;

 (func $get-blockstore-initial-block (export "get-blockstore-initial-block")
   (result i32)
   (call $get-blockstore-free-list))

 (func $is-blockstore-free-list-empty (export "is-blockstore-free-list-empty")
   (result i32)
   (call $is-last-free-block (call $get-blockstore-free-list)))

 (func $is-blockstore-relocating (export "is-blockstore-relocating")
   (result i32)
   (i32.ne (call $get-blockstore-current-relocation) (global.get $null)))

 (func $decr-blockstore-block-count (export "decr-blockstore-block-count")
   (call $set-blockstore-block-count (i32.sub (call $get-blockstore-block-count)
                                              (i32.const 1))))

 (func $incr-blockstore-block-count (export "incr-blockstore-block-count")
   (call $set-blockstore-block-count (i32.add (call $get-blockstore-block-count)
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
 ;; Blockstore Initialization
 ;;

 (func $init-blockstore (export "init-blockstore")
   (param $bottom i32)
   (param $top i32)

   (local $free-block i32)

   (global.set $blockstore-bottom (local.get $bottom))
   (global.set $blockstore-top (local.get $top))

   (global.set $blockstore-block-count (i32.const 1))
   (global.set $blockstore-relocation-offset (i32.const 0))
   (global.set $blockstore-current-relocation (global.get $null))
   (global.set $blockstore-relocation-end (global.get $null))

   (local.set $free-block (call $get-blockstore-free-list))
   (call $make-free-block
         (local.get $free-block)
         (i32.const 1)
         (global.get $null))

   (global.set $blockstore-free-area (call $get-next-block (local.get $free-block))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blockstore Relocation
 ;;

 (func $begin-relocate-blockstore (export "begin-relocate-blockstore")
   (param $offset i32)

   (local $free-area i32)

   (local.set $free-area (call $get-blockstore-free-area))

   (call $set-blockstore-current-relocation (call $get-blockstore-bottom))
   (call $set-blockstore-relocation-end (local.get $free-area))
   (call $set-blockstore-relocation-offset (local.get $offset))

   (call $set-blockstore-free-area (i32.add (local.get $free-area)
                                            (local.get $offset))))

 (func $end-relocate-blockstore (export "end-relocate-blockstore")
   (call $set-blockstore-current-relocation (global.get $null))
   (call $set-blockstore-relocation-end (global.get $null))
   (call $set-blockstore-relocation-offset (i32.const 0)))

 (func $relocate-free-block (export "relocate-free-block")
   (param $free-block i32)

   (local $next-free-block i32)
   (local $offset i32)

   (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
   (local.set $offset (call $get-blockstore-relocation-offset))

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

   (local.set $offset (call $get-blockstore-relocation-offset))
   (local.set $relocated-block (i32.add (local.get $block) (local.get $offset)))

   (call $set-block-value-block
         (local.get $block-owner)
         (local.get $relocated-block))

   (memory.copy (local.get $relocated-block)
                (local.get $block)
                (call $get-block-size (local.get $block))))

 (func $step-relocate-blockstore (export "step-relocate-blockstore")

   (local $block i32)
   (local $block-ref i32)

   (local.set $block (call $get-blockstore-current-relocation))

   (if (call $is-free-block (local.get $block))
       (then
        (call $relocate-free-block (local.get $block)))
     (else
      (call $relocate-block (local.get $block))))

   (local.set $block (call $get-next-block (local.get $block)))

   (if (i32.eq (local.get $block) (call $get-blockstore-relocation-end))
       (then
        (call $end-relocate-blockstore))
     (else
      (call $set-blockstore-current-relocation (local.get $bloc)))))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Blockstore Compaction
 ;;

 (func $step-blockstore-compact (export "step-blockstore-compact")

   (local $block-moved i32)
   (local $block-orig i32)
   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-free-length i32)
   (local $next-next-free-block i32)

   (if (i32.and (i32.eqz (call $is-blockstore-relocating))
                (i32.eqz (call $is-blockstore-free-list-empty)))
       (then

        (local.set $free-block (call $get-blockstore-free-list))
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
 ;; Blockstore Allocation
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

      (call $incr-blockstore-block-count)
      (i32.const 1))))

 (func $alloc-exact-free-list-block (export "alloc-exact-free-list-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $new-block i32)

   (local.set $free-block (call $get-blockstore-free-list))
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

   (local.set $free-block (call $get-blockstore-free-list))
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

 (func $ensure-blockstore-alloc-top (export "ensure-blockstore-alloc-top")
   (param $alloc-top i32)

   (local $memory-size i32)
   (local $size-required i32)
   (local $top i32)

   (local.set $top (call $get-blockstore-top))

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

        (call $set-blockstore-top (i32.shl (local.get $size-required)
                                           (global.get $page-size-bits))))))

 (func $alloc-end-block (export "alloc-end-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-free-list-end-block i32)
   (local $new-block i32)

   (local.set $new-block (call $get-blockstore-free-area))

   (call $ensure-blockstore-alloc-top
         (i32.add (local.get $new-block)
                  (call $calc-block-size (local.get $length))))

   (call $set-block-owner
         (local.get $new-block)
         (local.get $owner))

   (call $set-block-length
         (local.get $new-block)
         (local.get $length))

   (call $set-blockstore-free-area (call $get-next-block (local.get $new-block)))

   (call $incr-blockstore-block-count)

   (local.get $new-block))

 (func $alloc-block (export "alloc-block")
   (param $owner i32)
   (param $n i32)
   (result i32)

   (local $new-block i32)

   (if (i32.eqz (local.get $n))
       (then (return (global.get $null))))

   (if (i32.eqz (call $is-blockstore-relocating))
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
 ;; Blockstore Deallocation
 ;;

 (func $add-free-block (export "add-free-block")
   (param $block i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $offset i32)

   (local.set $free-block (call $get-blockstore-free-list))

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

        (if (call $is-blockstore-relocating)
            (then
             (call $relocate-free-block (local.get $free-block))
             (call $relocate-free-block (local.get $block))))))))

 (func $join-adjacent-free-blocks (export "join-adjacent-free-blocks")
   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-block (call $get-next-free-block (call $get-blockstore-free-list)))

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
               (call $decr-blockstore-block-count))
            (else
             (local.set $free-block (local.get $next-free-block))))
          (br $again)))))

 (func $drop-free-block-at-end (export "drop-free-block-at-end")

   (local $free-area i32)
   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-area (call $get-blockstore-free-area))
   (local.set $free-block (call $get-blockstore-free-list))

   (loop $again
     (if (i32.eqz (call $is-last-free-block (local.get $free-block)))
         (then
          (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
          (if (i32.eq (call $get-next-block (local.get $next-free-block))
                      (local.get $free-area))
              (then
               (call $set-next-free-block (local.get $free-block) (global.get $null))
               (call $set-blockstore-free-area (local.get $next-free-block))
               (call $decr-blockstore-block-count))
            (else
             (local.set $free-block (local.get $next-free-block))
             (br $again)))))))

 (func $compact-block-free-list (export "compact-block-free-list")

   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-block (call $get-blockstore-free-list))

   (if (i32.eqz (call $is-blockstore-free-list-empty))
       (then
        (call $join-adjacent-free-blocks)
        (call $drop-free-block-at-end))))

 (func $dealloc-block (export "dealloc-block")
   (param $block i32)

   (call $add-free-block (local.get $block))

   (if (i32.eqz (call $is-blockstore-relocating))
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
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-uncertain)))

 (func $mark-pair-scanned (export "mark-pair-scanned")
   (param $pair i32)
   (call $clear-pair-flag (local.get $pair) (global.get $pair-flag-uncertain)))

 (func $mark-block-reachable (export "mark-block-reachable")
   (param $block i32)

   (local $addr i32)
   (local $current-pair i32)
   (local $length i32)
   (local $end-pair i32)

   (call $set-pair-flags (local.get $block) (global.get $pair-flag-reachable))

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
