(module

 ;; Pairs
 ;;
 ;; Pairs are the fundamental data type, from which values of all other types
 ;; are referenced.

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
 ;; freelist.  The remainder of the page is composed of pairs available for use.
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
 ;; allocating from its freelist. A page has an open frontier when the lowest
 ;; address allocated pair is above the highest allocated pair in the block
 ;; list. When the page has an open frontier, allocation simply takes the next
 ;; lower pair. After the frontier has closed, the page uses its freelist. The
 ;; freelist is a stack that builds down from the pair flags area to just above
 ;; the page attributes. When the freelist is empty, the page scans the pair
 ;; flags area by groups of 64 bits (that, is 32 pairs), starting from high
 ;; memory to low. Any free pairs have their offsets added to the pair list.
 ;; When the page is fully allocated, the frontier allocator returns #null,
 ;; triggering the main allocator to activate the next page.  Each return pair
 ;; is marked in the pair flags area as pending a scan for reachablilty.  There
 ;; are 32 smudge bits in the page attributes.  Each smudge bit corresponds to a
 ;; block of 64 flag bits, and the bit will be set when at least one of the
 ;; corresponding pairs needs a reachability scan. Every allocation also
 ;; triggers an index maintenance step, moving index entries to higher memory to
 ;; make space for an additional memory page below the lowest index page.
 ;;
 ;; When a reference to a system root, a pair, or a vector is changed, the
 ;; transitive closure of the old target of the reference is immediately marked
 ;; as pending, and the appropriate smudge bits are set.  In addition, one
 ;; reachability check is made.  The lowest page with with a set smudge flag is
 ;; the target of the check.  One of the flag groups with a set bit is selected
 ;; -- the highest in memory -- and all pairs with a pending reachability scan
 ;; are checked.  A pending pair is reachable if it has an index entry where the
 ;; target is reachable.  If so, its pending state is changed to reachable.
 ;; Otherwise, the pair is unreachable and it is deallocated, its offset is
 ;; added to the page freelist, and any index entries where it is the target
 ;; have the target value set to #null. If the pair is the owner of a memory
 ;; block, such as a vector, string, or bytearray, then the corresponding block
 ;; is deallocated.
 ;;
 ;; Pair allocation begins with the currently active page.  If the page's
 ;; freelist is empty, then any smudges are processed for reachability until
 ;; there are either no more smudges or the freelist is no longer empty.  If the
 ;; freelist is empty and there are no smudges left, then the next page is
 ;; activated, and the process restarts with the newly active page's freelist
 ;; Once there is a non-empty freelist, the new cell is the value of the cdr of
 ;; the freelist, and the cdr of the freelist is set to the cddr of the
 ;; freelist.  One step of index maintenance is done, the pair is marked pending
 ;; a reachability check in the pair state flags, and the free count is
 ;; decremented.
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

 ;; addresses in page 0
 (global $memory-page-count  (export "memory-page-count")  i32 (i32.const 0x00000000))
 (global $memory-active-page (export "memory-active-page") i32 (i32.const 0x00000002))
 (global $memory-blockstore  (export "memory-blockstore")  i32 (i32.const 0x00000004))

 (global $page-flags                   (export "page-flags")                   i32 (i32.const 0x0000))
 (global $page-free-count              (export "page-free-count")              i32 (i32.const 0x0002))
 (global $page-free-scan-current-group (export "page-free-scan-current-group") i32 (i32.const 0x0004))
 (global $page-pair-bottom             (export "page-pair-bottom")             i32 (i32.const 0x0008))
 (global $page-next-free-pair          (export "page-next-free-pair")          i32 (i32.const 0x000c))
 (global $page-smudge-flags            (export "page-smudge-flags")            i32 (i32.const 0x0010))
 (global $page-freelist-head           (export "page-freelist-head")           i32 (i32.const 0x0014))

 ;; The freelist is a top down stack of free cells located in batches after the page frontier
 ;; has closed. When the freelist is empty, the value at page+page-freelist-head will be
 ;; page+page-freelist-top. When it is full, it will be page+page-freelist-bottom.
 (global $page-freelist-bottom         (export "page-freelist-bottom")         i32 (i32.const 0x0018))
 (global $page-freelist-top            (export "page-freelist-top")            i32 (i32.const 0x0040))

 (global $page-flag-frontier-closed    (export "page-flag-frontier-closed")    i32 (i32.const 0x0001))

 (global $page-pair-flags-area         (export "page-pair-flags-area")         i32 (i32.const 0x0040))
 (global $page-pair-flags-byte-length  (export "page-pair-flags-byte-length")  i32 (i32.const 0x07c0))
 (global $page-initial-bottom          (export "page-initial-bottom")          i32 (i32.const 0x0800))
 (global $page-free-scan-end-group     (export "page-free-scan-end-group")     i32 (i32.const 0x07c8))
 (global $page-initial-free-count      (export "page-initial-free-count")      i32 (i32.const 0x1f00))
 (global $page-offset-mask             (export "page-offset-mask")             i32 (i32.const 0x0000ffff))

 ;; reserve 2K for the management area

 (global $pair-flag-reachable (export "pair-flag-reachable") i32 (i32.const 1))
 (global $pair-flag-pending   (export "pair-flag-pending")   i32 (i32.const 2))
 (global $pair-flags-mask     (export "pair-flags-mask")     i32 (i32.const 0x00000003))

 (global $pair-flag-reachable-i64-group i64 (i64.const 0x5555555555555555))
 (global $pair-flag-pending-i64-group   i64 (i64.const 0xaaaaaaaaaaaaaaaa))

 (global $pair-smudge-shift (export "pair-smudge-shift") i32 (i32.const 8))
 (global $smudge-flag-shift-mask (export "smudge-flag-shift-mask") i32 (i32.const 0x1f))

 (global $max-trace-depth (export "max-trace-depth") i32 (i32.const 6))

 ;; The pair page base mask gives the base address of the page containing
 ;; a pair when the mask is applied to the pair value.
 (global $pair-page-base-mask (export "pair-flag-reachable-i64-group") i32 (i32.const 0xffff0000))

 ;; The pair page offset mask gives the offset from the page base to the
 ;; address of the values in the pair. Note that this is different from the
 ;; page-page-offset mask, in that this is designed to strip out the tag
 ;; bits at the bottom of the value.
 (global $pair-page-offset-mask (export "pair-page-offset-mask") i32 (i32.const 0x0000fff8))

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

 ;; Values
 ;;
 ;; Each pair contains two values. These are tagged to indicate what kind of
 ;; value they hold. The tag occupies the low 3 or 5 bits of the value.
 ;;
 ;; The rationale for the tag assignments below follows from an attempt to
 ;; arrange small integer arithmetic and pair dereferencing as to be as
 ;; efficient as possible.
 ;;
 ;; Small integer considerations are that the small integer tag is 0, and
 ;; that the tag bits are in the low bits of the word. Together these allow
 ;; small integer operations without any shifts or masking.
 ;;
 ;; The allowance for pairs is the split of tags between a 3 bit group and a 5
 ;; bit group. With 4 byte words, and therefore 8 byte pairs, all pair addresses
 ;; will have the lower 3 bits 0. Hence, to transform a pair value to a pair
 ;; address only requires a mask. Unfortunately, there are more than 8 value
 ;; types, so small tag 7 indicates a large tag, with the remaining value types
 ;; encoded in two more bits.
 ;;

 (global $tag-mask          (export "tag-mask")          i32 (i32.const 0x07))

 (global $tag-small-integer (export "tag-small-integer") i32 (i32.const 0x00))
 (global $tag-block         (export "tag-block")         i32 (i32.const 0x01))
 (global $tag-box           (export "tag-box")           i32 (i32.const 0x02))
 (global $tag-char          (export "tag-char")          i32 (i32.const 0x03))
 (global $tag-pair          (export "tag-pair")          i32 (i32.const 0x04))
 (global $tag-procedure     (export "tag-procedure")     i32 (i32.const 0x05))
 (global $tag-symbol        (export "tag-symbol")        i32 (i32.const 0x06))
 (global $tag-singleton     (export "tag-singleton")     i32 (i32.const 0x07))

 ;; block types include vector, string, and bytearray.  These have additional
 ;; storage in a block storage page.  The car of the pair the value addresses
 ;; refers to the type of the block, the cdr is the address of the block head.

 ;; box types include native code and ports.  They are contained within a pair.
 ;; the car of the pair the value addresses refers to the type of the box, the
 ;; cdr is an opaque scalar which provides its value.

 ;; singletons
 (global $eof   (export "#eof-object") i32 (i32.const 0xeee00fff))
 (global $false (export "#false")      i32 (i32.const 0x0000001f))
 (global $null  (export "#null")       i32 (i32.const 0xffffffff))
 (global $true  (export "#true")       i32 (i32.const 0x0000003f))


 (global $blockvalue-type  (export "blockvalue-type")  i32 (i32.const 0x0000))
 (global $blockvalue-block (export "blockvalue-block") i32 (i32.const 0x0004))

 (func $set-blockvalue-block (export "set-blockvalue-block")
   (param $blockvalue i32)
   (param $block i32)
   (i32.store (i32.add (local.get $blockvalue)
                       (global.get $blockvalue-block))
              (local.get $block)))

 (func $get-blockstore (export "get-blockstore")
   (result i32)
   (i32.load (global.get $memory-blockstore)))

 (func $set-blockstore (export "set-blockstore")
   (param $blockstore i32)
   (i32.store (global.get $memory-blockstore)
              (local.get $blockstore)))

 (func $get-active-page (export "get-active-page")
   (result i32)
   (i32.shl (i32.load16_u (global.get $memory-active-page)) (i32.const 16)))

 (func $activate-next-page (export "activate-next-page")

   (local $active-page i32)
   (local $page-count i32)

   (local.set $active-page
              (i32.add (i32.load16_u (global.get $memory-active-page))
                       (i32.const 1)))

   (local.set $page-count (i32.load16_u (global.get $memory-page-count)))

   (i32.store16 (global.get $memory-active-page) (local.get $active-page))

   (if (i32.gt_u (local.get $active-page) (local.get $page-count))
       (then
        (i32.store16
         (global.get $memory-page-count)
         (i32.add (local.get $page-count) (i32.const 1)))
        (call $init-page (memory.grow (i32.const 1))))))

 ;; Vectors
 ;;
 ;; A vector is represented by a pair and a contiguous sequence of pairs
 ;; which hold its values. The former is the vector itself, the latter is
 ;; its storage array.
 ;;
 ;; A vector value holds the address of that pair. The first value of the pair
 ;; is the address of a contiguous sequence of pairs holding the vector's
 ;; values.  The second value is the vector length, stored as a small integer.
 ;;
 ;; The top pair of a page is reserved for the head of the vector storage
 ;; list. The first value of that pair is always null, the second is the address
 ;; of first storage array in the list. Each storage array is a contiguous
 ;; sequence of pairs. The second and subsequent pairs in the array contain the
 ;; values of the vector. The pair links the storage array to rest of the list
 ;; of storage arrays, and to the vector for which the storage array holds
 ;; values. The first value is the address of the pair representing the vector,
 ;; the second is the link to the next storage array. The last storage array
 ;; links to the head, forming a circular list. That the head has a null vector
 ;; distinguishes it from all other items. In general the first array in the
 ;; list will be in the lowest position in memory and subsequent items will be
 ;; higher, as new arrays are allocated from the top down.
 ;;
 ;; Vectors with an excess of 30K values will have a separate array storage
 ;; representation (TBD).
 ;;
 ;; Since the vector and its storage are represented as ordinary pairs, they are
 ;; managed by the same garbage collection as ordinary pairs. After a vector has
 ;; found unreachable, its storage will be reclaimed by compacting the vector
 ;; storage area upward and adjusting vector storage addresses, storage array
 ;; list links, and memory marks as appropriate. This activity may occur
 ;; immediately after a vector found to be unreachable, or at some convenient
 ;; time thereafter.
 ;;

 (func $value-tag (export "value-tag")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $tag-mask)))

 (func $pair-page-base (export "pair-page-base")
   (param $pair i32)
   (result i32)

   (i32.and (local.get $pair) (global.get $pair-page-base-mask)))

 (func $pair-page-offset (export "pair-page-offset")
   (param $pair i32)
   (result i32)

   (i32.and (local.get $pair) (global.get $pair-page-offset-mask)))

 (func $get-pair-flags-location (export "get-pair-flags-location")
   (param $pair i32)
   (result i32 i32)

   (local $pair-offset i32)
   (local.set $pair-offset (call $pair-page-offset (local.get $pair)))

   (i32.add
    (call $pair-page-base (local.get $pair))
    (i32.shr_u (local.get $pair-offset) (global.get $pair-flag-addr-shift)))

   (i32.shr_u
    (i32.and
     (local.get $pair-offset)
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

 (func $set-all-pair-flags (export "set-all-pair-flags")
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

 (func $mark-pair-reachable (export "mark-pair-reachable")
   (param $pair i32)
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-reachable))
   (if (i32.and
        (call $get-pair-flags (local.get $pair))
        (global.get $pair-flag-pending))
       (then
        (call $set-group-smudge (local.get $pair)))))

 (func $mark-pair-dirty (export "mark-pair-dirty")
   (param $pair i32)
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-pending)))

 (func $mark-pair-scanned (export "mark-pair-scanned")
   (param $pair i32)
   (call $clear-pair-flag (local.get $pair) (global.get $pair-flag-pending)))

 (func $pair-smudge-flag-addr (export "pair-smudge-flag-addr")
   ;; returns the address of the smudge flags for the given pair
   (param $pair i32)
   (result i32)

   (i32.add
    (call $pair-page-base (local.get $pair))
    (global.get $page-smudge-flags)))

 (func $pair-smudge-flag-shift (export "pair-smudge-flag-shift")
   ;; returns the bit position in the smudge flags for the given pair
   (param $pair i32)
   (result i32)

   (i32.and
    (i32.shr_u (local.get $pair) (global.get $pair-smudge-shift))
    (global.get $smudge-flag-shift-mask)))

 (func $set-group-smudge (export "set-group-smudge")
   ;; sets the smudge flag for a group of pair flags, indicating that at least
   ;; one of the pairs in that group is both reachable and has a pending trace.
   (param $pair i32)

   (local $smudge-flag-addr i32)
   (local.set $smudge-flag-addr (call $pair-smudge-flag-addr (local.get $pair)))

   (i32.store (local.get $smudge-flag-addr)
              (i32.or
               (i32.load (local.get $smudge-flag-addr))
               (i32.shl
                (i32.const 1)
                (call $pair-smudge-flag-shift (local.get $pair))))))

 (func $clear-group-smudge (export "clear-group-smudge")
   ;; clears the smudge flag for a group of pair flags, indicating that none of
   ;; the pairs in that group is both reachable and has a pending trace.
   (param $pair i32)

   (local $smudge-flag-addr i32)
   (local.set $smudge-flag-addr (call $pair-smudge-flag-addr (local.get $pair)))

   (i32.store (local.get $smudge-flag-addr)
              (i32.and
               (i32.load (local.get $smudge-flag-addr))
               (i32.shl
                (i32.const -2) ;; all bits set, except bit 0
                (call $pair-smudge-flag-shift (local.get $pair))))))

 (func $mark-block-reachable (export "mark-block-reachable")
   (param $block i32)

   (local $addr i32)
   (local $current-pair i32)
   (local $length i32)
   (local $end-pair i32)

   (call $set-all-pair-flags (local.get $block) (global.get $pair-flag-reachable))

   ;; clear tag bits to convert block to a pair address
   (local.set $addr (i32.and (local.get $block) (i32.xor (global.get $tag-mask) (i32.const -1))))

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

 (func $trace-value (export "trace-value")
   (param $depth i32)
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $value-tag (local.get $value)))

   (if (i32.eq (local.get $tag) (global.get $tag-block))
       (then
        (call $mark-block-reachable (local.get $value)))
     (else
      (if (i32.eq (local.get $tag) (global.get $tag-pair))
          (then
           (call $mark-pair-reachable (local.get $value))
           (if (i32.gt_u (local.get $depth) (i32.const 0))
               (then
                (call $trace-pair (i32.sub (local.get $depth) (i32.const 1))
                      (local.get $value)))))))))

 (func $trace-pair (export "trace-pair")
   (param $depth i32)
   (param $pair i32)

   (local $addr i32)

   (local.set $addr (call $pair-page-base (local.get $pair)))

   (call $trace-value (local.get $depth) (i32.load (local.get $addr)))
   (call $trace-value (local.get $depth) (i32.load (i32.add (local.get $addr)
                                                            (global.get $value-size))))

   (call $mark-pair-scanned (local.get $pair)))

 (func $get-group-ready-pair-map (export "get-group-ready-pair-map")
   (param $flags i64)
   (result i64)

   (i64.and ;; see $get-group-free-pair-map below, uses or
    (i64.shr_u (i64.and (global.get $pair-flag-pending-i64-group)
                        (local.get $flags))
               (i64.const 1))
    (i64.and (global.get $pair-flag-reachable-i64-group)
             (local.get $flags))))

 (func $get-group-free-pair-map (export "get-group-free-pair-map")
   (param $flags i64)
   (result i64)

   (i64.xor (global.get $pair-flag-reachable-i64-group)
            (i64.or ;; see $get-group-ready-pair-map above, uses and
             (i64.shr_u (i64.and (global.get $pair-flag-pending-i64-group)
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

 (func $get-ready-map-trace-depth (export "get-ready-map-trace-depth")
   (param $ready-pair-map i64)
   (result i32)

   (local $count-ready i32)
   (local.set $count-ready (i32.wrap_i64 (i64.popcnt (local.get $ready-pair-map))))

   ;; roughly log2 ( 32 / count-ready )
   (i32.sub (global.get $max-trace-depth)
            (i32.sub
             (i32.const 32)
             (i32.clz (local.get $count-ready)))))

 (func $trace-group (export "trace-group")
   (param $page i32)
   (param $group i32)

   (local $ready-pair-map i64)
   (local $depth i32)
   (local $pair-offset i32)

   (call $clear-group-smudge (local.get $group))

   (local.set $ready-pair-map
              (call $get-group-ready-pair-map
                    (i64.load (local.get $group))))

   (local.set $depth (call $get-ready-map-trace-depth (local.get $ready-pair-map)))

   (local.set $pair-offset (call $get-flag-group-pair-offset (local.get $group)))

   (loop $again
     (if (i64.ne (local.get $ready-pair-map) (i64.const 0))
         (then
          (call $next-pair-offset (local.get $ready-pair-map) (local.get $pair-offset))
          (local.set $pair-offset)
          (local.set $ready-pair-map)

          (call $trace-pair (local.get $depth) (i32.add (local.get $page)
                                                        (local.get $pair-offset)))

          (local.set $pair-offset (i32.add (local.get $pair-offset) (global.get $pair-size)))

          (br $again)))))

 (func $collection-step (export "collection-step")
   ;; find next smudged flag group
   ;; trace group
   ;; if no smudged flag groups
   ;;    end collection
   nop
   )

 (func $begin-collection (export "begin-collection")
   ;; mark roots as reachable
   ;; mark vector storage list head as reachable
   ;; set scan pointers to 0
   nop)

 (func $collection-complete? (export "collection-complete?")
   nop)

 (func $end-collection (export "end-collection")
   ;; clear all pending flags (pending but unreachable should be freed)
   ;; change all reachable flags to pending flags
   ;; compact vector storage
   ;; compact string storage
   ;; compact bytearray storage
   nop)

 ;; Pair Allocator

 (func $page-decr-free-count (export "page-decr-free-count")
   (param $page i32)

   (local $free-count-addr i32)
   (local.set $free-count-addr (i32.add (local.get $page) (global.get $page-free-count)))

   (i32.store
    (local.get $free-count-addr)
    (i32.sub (i32.load (local.get $free-count-addr)) (i32.const 1))))

 (func $fill-page-freelist-from-free-pair-map (export "fill-page-freelist-from-free-pair-map")
   ;; Translates an i64 extract from the pair flags area into a set of offsets to be
   ;; stored in the freelist. Offsets are stored in the freelist from high memory to
   ;; low. The start of the freelist is stored at page + page-freelist-head. If the start is
   ;; equal to page + page-freelist-top, then the freelist is empty. If it is equal to
   ;; page + page-freelist-bottom.
   (param $page i32)
   (param $group i32)
   (param $free-pair-map i64)

   (local $freelist-head-addr i32)
   (local $freelist-head i32)
   (local $freelist-bottom i32)

   (local $pair-offset i32)

   (local.set $freelist-head-addr (i32.add (local.get $page) (global.get $page-freelist-head)))
   (local.set $freelist-head (i32.load (local.get $freelist-head-addr)))
   (local.set $freelist-bottom (i32.add (local.get $page) (global.get $page-freelist-bottom)))

   ;; The flags map has 2 bits per 8 byte pair, so to translate the group address to the address
   ;; of the pairs it pertains to, the address needs to be shifted left 5 bit positions (x32),
   ;; corresponding to the ratio of 2 bits to 8 bytes (2 to 64).

   (local.set $pair-offset (call $get-flag-group-pair-offset (local.get $group)))

   (loop $again
     (if (i32.and
          (i64.ne (local.get $free-pair-map) (i64.const 0))
          (i32.gt_u (local.get $freelist-head) (local.get $freelist-bottom)))
         (then

          (local.set $freelist-head (i32.sub (local.get $freelist-head)
                                             (global.get $offset-size)))

          (call $next-pair-offset (local.get $free-pair-map) (local.get $pair-offset))
          (local.set $pair-offset)
          (local.set $free-pair-map)

          (i32.store16 (local.get $freelist-head) (local.get $pair-offset))

          ;; advance pair-offset to account for space used by the free pair just located
          (local.set $pair-offset (i32.add (local.get $pair-offset) (global.get $pair-size)))

          (br $again))))

   (i32.store (local.get $freelist-head-addr) (local.get $freelist-head)))

 (func $fill-page-freelist (export "fill-page-freelist")
   (param $page i32)

   (local $current-group-addr i32)
   (local $current-group i32)
   (local $end-group i32)

   (local $freelist-head-addr i32)
   (local $freelist-bottom i32)
   (local $free-pair-map i64)

   (local.set $current-group-addr (i32.add (local.get $page) (global.get $page-free-scan-current-group)))
   (local.set $current-group (i32.load (local.get $current-group-addr)))
   (local.set $end-group (i32.add (local.get $page) (global.get $page-pair-flags-area)))

   (local.set $freelist-head-addr (i32.add (local.get $page) (global.get $page-freelist-head)))
   (local.set $freelist-bottom (i32.add (local.get $page) (global.get $page-freelist-bottom)))

   (loop $again
     (if (i32.and
          (i32.ge_u (local.get $current-group) (local.get $end-group))
          (i32.gt_u (i32.load (local.get $freelist-head-addr)) (local.get $freelist-bottom)))
         (then
          (local.set $free-pair-map
                     (call $get-group-free-pair-map
                           (i64.load (local.get $current-group))))
          (call $fill-page-freelist-from-free-pair-map
                (local.get $page)
                (local.get $current-group)
                (local.get $free-pair-map))
          (local.set $current-group (i32.sub (local.get $current-group) (global.get $group-size)))
          (br $again))))

   (i32.store (local.get $current-group-addr) (local.get $current-group)))

 (func $page-alloc-freelist-pair (export "page-alloc-freelist-pair")
   (param $page i32)
   (result i32)

   (local $freelist-head-addr i32)
   (local $freelist-head i32)
   (local $freelist-top i32)
   (local $new-pair i32)

   (local.set $freelist-head-addr (i32.add (local.get $page) (global.get $page-freelist-head)))
   (local.set $freelist-head (i32.load (local.get $freelist-head-addr)))
   (local.set $freelist-top (i32.add (local.get $page) (global.get $page-freelist-top)))

   (if (i32.eq (local.get $freelist-head) (local.get $freelist-top))
       (then
        (call $fill-page-freelist (local.get $page))
        (local.set $freelist-head (i32.load (local.get $freelist-head-addr)))))

   (if (result i32) (i32.eq (local.get $freelist-head) (local.get $freelist-top))
     (then
      (global.get $null))

     (else
      (local.set $new-pair (i32.add (local.get $page) (i32.load16_u (local.get $freelist-head))))

      (call $mark-pair-dirty (local.get $new-pair))
      (call $page-decr-free-count (local.get $page))

      (i32.store (local.get $freelist-head-addr)
                 (i32.add (local.get $freelist-head) (global.get $offset-size)))

      (local.get $new-pair))))

 (func $page-frontier-closed? (export "page-frontier-closed?")
   (param $page i32)
   (result i32)

   (local $flags-addr i32)
   (local.set $flags-addr (i32.add (local.get $page) (global.get $page-flags)))
   (i32.and (global.get $page-flag-frontier-closed) (i32.load16_u (local.get $flags-addr))))

 (func $close-page-frontier (export "close-page-frontier")
   (param $page i32)

   (local $flags-addr i32)
   (local.set $flags-addr (i32.add (local.get $page) (global.get $page-flags)))

   (i32.store16
    (local.get $flags-addr)
    (i32.or (global.get $page-flag-frontier-closed) (i32.load (local.get $flags-addr))))

   (call $fill-page-freelist (local.get $page)))

 (func $page-alloc-frontier-pair (export "page-alloc-frontier-pair")
   (param $page i32)
   (result i32)

   (local $next-free-pair-addr i32)
   (local $next-free-pair i32)
   (local $new-pair i32)

   (local.set $next-free-pair-addr (i32.add (local.get $page) (global.get $page-next-free-pair)))
   (local.set $new-pair (i32.load (local.get $next-free-pair-addr)))

   (call $mark-pair-dirty (local.get $new-pair))
   (call $page-decr-free-count (local.get $page))

   (local.set $next-free-pair (i32.sub (local.get $new-pair) (global.get $pair-size)))

   (if (i32.eq (local.get $next-free-pair)
               (i32.load (i32.add (local.get $page) (global.get $page-pair-bottom))))
       (then
        (call $close-page-frontier (local.get $page)))
     (else
      (i32.store (local.get $next-free-pair-addr) (local.get $next-free-pair))))

   (local.get $new-pair))

 (func $alloc-pair (export "alloc-pair")
   (result i32)

   (local $new-pair i32)

   (local $page i32)
   (local.set $page (call $get-active-page))

   (if (result i32) (call $page-frontier-closed? (local.get $page))
     (then
      (local.set $new-pair (call $page-alloc-freelist-pair (local.get $page)))
      (if (result i32) (i32.eq (local.get $new-pair) (global.get $null))
        (then
         (call $activate-next-page)
         (call $alloc-pair))
        (else
         (local.get $new-pair))))
     (else (call $page-alloc-frontier-pair (local.get $page)))))

 ;; Pair Functions

 (func $make-pair (export "make-pair")
   (param $car i32)
   (param $cdr i32)
   (result i32)

   (local $pair-addr i32)
   (local.set $pair-addr (call $alloc-pair))

   (i32.store (local.get $pair-addr) (local.get $car))
   (i32.store (i32.add (local.get $pair-addr) (global.get $value-size)) (local.get $cdr))

   (i32.or (local.get $pair-addr) (global.get $tag-pair)))

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

 (func $init-block-list (export "init-block-list")
   (param $page i32)

   (local $bottom-addr i32)
   (local $bottom i32)

   (local.set $bottom-addr (i32.add (local.get $page) (global.get $page-pair-bottom)))
   (local.set $bottom (i32.load (local.get $bottom-addr)))

   (i32.store (local.get $bottom) (global.get $null))
   (i32.store (i32.add (local.get $bottom) (global.get $value-size)) (global.get $null))

   (call $mark-pair-dirty (local.get $bottom))
   (call $page-decr-free-count (local.get $page))

   (i32.store
    (local.get $bottom-addr)
    (i32.add (local.get $bottom) (global.get $pair-size))))

 ;; Pages
 ;; Memory page 0, the lowest 64KB, is used to manages pages 1 and up.

 (func $init-page (export "init-page")
   (param $page-idx i32)

   (local $page i32)
   (local $pair-flags-area i32)

   ;; Applying this to the 0 page corrupts everything.
   (if (i32.eqz (local.get $page-idx)) (unreachable))

   (local.set $page (i32.shl (local.get $page-idx)
                             (global.get $page-size-bits)))
   (local.set $pair-flags-area (i32.add (local.get $page) (global.get $page-pair-flags-area)))

   (memory.fill
    (local.get $page)
    (i32.const 0)
    (global.get $page-initial-bottom))

   (i32.store16
    (i32.add (local.get $page) (global.get $page-free-count))
    (global.get $page-initial-free-count))

   (i32.store
    (i32.add (local.get $page) (global.get $page-free-scan-current-group))
    (i32.add (local.get $page)
             (i32.sub (global.get $page-initial-bottom)
                      (global.get $group-size))))

   (i32.store
    (i32.add (local.get $page) (global.get $page-pair-bottom))
    (i32.add (local.get $page) (global.get $page-initial-bottom)))

   (i32.store
    (i32.add (local.get $page) (global.get $page-next-free-pair))
    (i32.add (local.get $page) (i32.sub (global.get $page-size)
                                        (global.get $pair-size))))

   (i32.store
    (i32.add (local.get $page) (global.get $page-freelist-head))
    (i32.add (local.get $page) (global.get $page-freelist-top)))

   (call $init-block-list (local.get $page)))

 (start $init)
 (func $init
   (i32.store16 (global.get $memory-active-page) (i32.const 0))
   (i32.store16 (global.get $memory-page-count)  (i32.const 0))
   (call $activate-next-page))


 ;; Block storage area page header

 ;; Count of 64Ki pages (contiguous) in the block storage area

 ;; Address of the first free block in the freelist.

 ;; When relocating, this is the offset from the current block storage area to
 ;; the target area. This will be a positive multiple of 64Ki during
 ;; relocations, zero otherwise.

 ;; When relocating, this is the address of the lowest block address that needs
 ;; to be relocated.

 ;; When relocating, this is the address of the highest block address that needs
 ;; to be relocated.

 ;; The initial blocklist and initial freelist consist of a single free block of
 ;; length -1.

 ;; Initializes the free block at the given address

 ;; Blockstore structure

 (global $blockstore-page-count         (export "blockstore-page-count")         i32 (i32.const 0x0000))
 (global $blockstore-block-count        (export "blockstore-block-count")        i32 (i32.const 0x0004))
 (global $blockstore-relocation-offset  (export "blockstore-relocation-offset")  i32 (i32.const 0x0008))
 (global $blockstore-relocation-block   (export "blockstore-relocation-block")   i32 (i32.const 0x000c))
 (global $blockstore-current-relocation (export "blockstore-current-relocation") i32 (i32.const 0x0010))
 (global $blockstore-free-area          (export "blockstore-free-area")          i32 (i32.const 0x0014))

 ;; Block structure

 (global $block-owner           (export "block-owner")           i32 (i32.const 0x0000))
 (global $block-length          (export "block-length")          i32 (i32.const 0x0004))
 (global $free-block-next-block (export "free-block-next-block") i32 (i32.const 0x0008))

 ;; Sizes and lengths

 (global $block-header-length    (export "block-header-length")    i32 (i32.const 2))
 (global $block-header-size      (export "block-header-size")      i32 (i32.const 0x0008))
 (global $blockstore-header-size (export "blockstore-header-size") i32 (i32.const 0x0018))

 ;; Blockstore getters and setters

 (func $get-blockstore-page-count (export "get-blockstore-page-count")
   (result i32)
   (i32.load (i32.add (call $get-blockstore)
                      (global.get $blockstore-page-count))))

 (func $get-blockstore-block-count (export "get-blockstore-block-count")
   (result i32)
   (i32.load (i32.add (call $get-blockstore)
                      (global.get $blockstore-block-count))))

 (func $get-blockstore-freelist (export "get-blockstore-freelist")
   (result i32)
   ;; The first block in the storage area is always the head of the free list.
   (i32.add (call $get-blockstore)
            (global.get $blockstore-header-size)))

 (func $get-blockstore-relocation-offset (export "get-blockstore-relocation-offset")
   (result i32)
   (i32.load (i32.add (call $get-blockstore)
                      (global.get $blockstore-relocation-offset))))

 (func $get-blockstore-relocation-block (export "get-blockstore-relocation-block")
   (result i32)
   (i32.load (i32.add (call $get-blockstore)
                      (global.get $blockstore-relocation-block))))

 (func $get-blockstore-current-relocation (export "get-blockstore-current-relocation")
   (result i32)
   (i32.load (i32.add (call $get-blockstore)
                      (global.get $blockstore-current-relocation))))

 (func $get-blockstore-free-area (export "get-blockstore-free-area")
   (result i32)
   (i32.load (i32.add (call $get-blockstore)
                      (global.get $blockstore-free-area))))

 (func $set-blockstore-page-count (export "set-blockstore-page-count")
   (param $page-count i32)
   (i32.store (i32.add (call $get-blockstore)
                       (global.get $blockstore-page-count))
              (local.get $page-count)))

 (func $set-blockstore-block-count (export "set-blockstore-block-count")
   (param $block-count i32)
   (i32.store (i32.add (call $get-blockstore)
                       (global.get $blockstore-block-count))
              (local.get $block-count)))

 (func $set-blockstore-relocation-offset (export "set-blockstore-relocation-offset")
   (param $relocation-offset i32)
   (i32.store (i32.add (call $get-blockstore)
                       (global.get $blockstore-relocation-offset))
              (local.get $relocation-offset)))

 (func $set-blockstore-relocation-block (export "set-blockstore-relocation-block")
   (param $relocation-block i32)
   (i32.store (i32.add (call $get-blockstore)
                       (global.get $blockstore-relocation-block))
              (local.get $relocation-block)))

 (func $set-blockstore-current-relocation (export "set-blockstore-current-relocation")
   (param $current-relocation i32)
   (i32.store (i32.add (call $get-blockstore)
                       (global.get $blockstore-current-relocation))
              (local.get $current-relocation)))

 (func $set-blockstore-free-area (export "set-blockstore-free-area")
   (param $free-area i32)
   (i32.store (i32.add (call $get-blockstore)
                       (global.get $blockstore-free-area))
              (local.get $free-area)))

 ;; Block getters and setters

 (func $get-block-owner (export "get-block-owner")
   (param $block i32)
   (result i32)
   (i32.load (i32.add (local.get $block)
                      (global.get $block-owner))))

 (func $get-block-length (export "get-block-length")
   (param $block i32)
   (result i32)
   (i32.load (i32.add (local.get $block)
                      (global.get $block-length))))

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

 ;; Block utility functions

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

 ;; Blockstore utility functions

 (func $get-blockstore-initial-block (export "get-blockstore-initial-block")
   (result i32)
   (call $get-blockstore-freelist))

 (func $get-blockstore-next-relocation-block (export "get-blockstore-next-relocation-block")
   (result i32)

   (local $current-relocation i32)

   (local.set $current-relocation (call $get-blockstore-current-relocation))

   (if (result i32) (i32.eq (local.get $current-relocation) (global.get $null))
     (then
      (i32.const 0))
     (else
      (i32.load (local.get $current-relocation)))))

 (func $get-blockstore-top (export "get-blockstore-top")
   (result i32)
   (i32.add (call $get-blockstore)
            (i32.shl (call $get-blockstore-page-count)
                     (global.get $page-size-bits))))

 (func $is-blockstore-freelist-empty (export "is-blockstore-freelist-empty")
   (result i32)
   (call $is-last-free-block (call $get-blockstore-freelist)))

 (func $is-blockstore-relocating (export "is-blockstore-relocating")
   (result i32)
   (i32.ne (call $get-blockstore-relocation-block) (global.get $null)))

 (func $decr-blockstore-block-count (export "decr-blockstore-block-count")
   (call $set-blockstore-block-count (i32.sub (call $get-blockstore-block-count)
                                              (i32.const 1))))

 (func $incr-blockstore-block-count (export "incr-blockstore-block-count")
   (call $set-blockstore-block-count (i32.add (call $get-blockstore-block-count)
                                              (i32.const 1))))

 ;; Constructors

 (func $make-free-block (export "make-free-block")
   (param $block i32)
   (param $length i32)
   (param $next-block i32)

   (call $set-block-owner     (local.get $block) (global.get $null))
   (call $set-block-length    (local.get $block) (local.get $length))
   (call $set-next-free-block (local.get $block) (local.get $next-block)))

 (func $init-blockstore (export "init-blockstore")
   (param $page-idx i32)
   (param $page-count i32)

   (local $free-block i32)

   (call $set-blockstore (i32.shl (local.get $page-idx)
                                  (global.get $page-size-bits)))

   (call $set-blockstore-page-count (local.get $page-count))
   (call $set-blockstore-block-count (i32.const 1))
   (call $set-blockstore-relocation-offset (i32.const 0))
   (call $set-blockstore-relocation-block (global.get $null))
   (call $set-blockstore-current-relocation (global.get $null))

   (local.set $free-block (call $get-blockstore-freelist))
   (call $make-free-block
         (local.get $free-block)
         (i32.const 1)
         (global.get $null))

  (call $set-blockstore-free-area (call $get-next-block (local.get $free-block))))

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
    ;; the freelist link address?
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

 (func $alloc-exact-freelist-block (export "alloc-exact-freelist-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $new-block i32)

   (local.set $free-block (call $get-blockstore-freelist))
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

 (func $alloc-split-freelist-block (export "alloc-split-freelist-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $new-block i32)

   (local.set $free-block (call $get-blockstore-freelist))
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

   (local $blockstore-top i32)

   (local.set $blockstore-top (call $get-blockstore-top))

   (if (i32.gt_u (local.get $alloc-top) (local.get $blockstore-top))
       (then
            (memory.grow (i32.add (i32.const 1)
                             (i32.shr_u (i32.sub
                                         (i32.sub (local.get $alloc-top)
                                                  (local.get $blockstore-top))
                                         (i32.const 1))
                                        (global.get $page-size-bits))))
            (drop))))

 (func $alloc-end-block (export "alloc-end-block")
   (param $owner i32)
   (param $length i32)
   (result i32)

   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-freelist-end-block i32)
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
        (local.set $new-block (call $alloc-exact-freelist-block
                                    (local.get $owner)
                                    (local.get $n)))

        (if (i32.ne (local.get $new-block) (global.get $null))
            (then
             (return (local.get $new-block))))

        (local.set $new-block (call $alloc-split-freelist-block
                                    (local.get $owner)
                                    (local.get $n)))

        (if (i32.ne (local.get $new-block) (global.get $null))
            (then
             (return (local.get $new-block))))))

   (call $alloc-end-block
         (local.get $owner)
         (local.get $n)))

 (func $add-free-block (export "add-free-block")
   (param $block i32)

   (local $block-as-next-free i32)
   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-relocation-block i32)
   (local $relocation-offset i32)

   (local.set $free-block (call $get-blockstore-freelist))

   (loop $again
     (local.set $next-free-block (call $get-next-free-block (local.get $free-block)))
     (if (i32.or
          (i32.eq (local.get $next-free-block) (global.get $null))
          (i32.gt_u (local.get $next-free-block)
                    (local.get $block)))
         (then
          (local.set $next-relocation-block (call $get-blockstore-next-relocation-block))
          (local.set $relocation-offset (call $get-blockstore-relocation-offset))

          (local.set $block-as-next-free (local.get $block))

          (if (i32.and (i32.ne (local.get $relocation-offset) (i32.const 0))
                       (i32.gt_u (local.get $block) (local.get $next-relocation-block)))
              (then
               (local.set $block
                          (i32.add (local.get $block)
                                   (local.get $relocation-offset)))

               (local.set $next-free-block
                          (i32.add (local.get $next-free-block)
                                   (local.get $relocation-offset)))

               (if (i32.gt_u (local.get $free-block) (local.get $next-relocation-block))
                   (then
                    (local.set $free-block
                               (i32.add (local.get $free-block)
                                        (local.get $relocation-offset)))

                    (local.set $block-as-next-free
                               (i32.add (local.get $block-as-next-free)
                                        (local.get $relocation-offset)))))))
          (call $set-next-free-block
                (local.get $free-block)
                (local.get $block-as-next-free))

          (call $set-next-free-block
                (local.get $block)
                (local.get $next-free-block)))
       (else
        (local.set $free-block (local.get $next-free-block))
        (br $again)))))

 (func $join-adjacent-free-blocks (export "join-adjacent-free-blocks")
   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-block (call $get-next-free-block (call $get-blockstore-freelist)))

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
   (local.set $free-block (call $get-blockstore-freelist))

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

 (func $compact-block-freelist (export "compact-block-freelist")

   (local $free-block i32)
   (local $next-free-block i32)

   (local.set $free-block (call $get-blockstore-freelist))

   (if (i32.eqz (call $is-blockstore-freelist-empty))
       (then
        (call $join-adjacent-free-blocks)
        (call $drop-free-block-at-end))))

 (func $dealloc-block (export "dealloc-block")
   (param $block i32)

   (call $add-free-block (local.get $block))

   (if (i32.eqz (call $is-blockstore-relocating))
       (then
        (call $compact-block-freelist))))

 (func $step-blockstore-compact (export "step-blockstore-compact")

   (local $block-moved i32)
   (local $block-orig i32)
   (local $free-block i32)
   (local $next-free-block i32)
   (local $next-free-length i32)
   (local $next-next-free-block i32)

   (if (i32.and (i32.eqz (call $is-blockstore-relocating))
                (i32.eqz (call $is-blockstore-freelist-empty)))
       (then

        (local.set $free-block (call $get-blockstore-freelist))
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

        (call $compact-block-freelist))))

 (func $fill-relocation-block (export "fill-relocation-block")
   (param $relocation-block i32)
   (result i32)

   (local $block i32)
   (local $block-ref i32)
   (local $end-ref i32)

   (local.set $block (call $get-blockstore-initial-block))

   (local.set $block-ref (i32.add (local.get $relocation-block)
                                  (global.get $block-header-size)))

   (local.set $end-ref (call $get-next-block (local.get $relocation-block)))

   (loop $again
     (i32.store (local.get $block-ref)
                (local.get $block))

     (if (i32.lt_u (local.get $block-ref) (local.get $end-ref))
         (then
          (local.set $block (call $get-next-block (local.get $block)))
          (local.set $block-ref (i32.add (local.get $block-ref)
                                         (global.get $value-size)))
          (br $again))))

   (local.get $relocation-block))

 (func $make-relocation-block (export "make-relocation-block")
   (result i32)

   (local $block-count i32)
   (local $relocation-block i32)

   (local.set $relocation-block (i32.add (call $get-blockstore-free-area)
                                         (call $get-blockstore-relocation-offset)))

   ;; add one to include the relocation block, which will become
   ;; a free block once relocation has finshed
   (local.set $block-count (i32.add (call $get-blockstore-block-count)
                                    (i32.const 1)))

   (call $ensure-blockstore-alloc-top
         (i32.add (local.get $relocation-block)
                  (call $calc-block-size (local.get $block-count))))

   (call $make-free-block
         (local.get $relocation-block)
         (local.get $block-count)
         (global.get $null))

   (call $fill-relocation-block (local.get $relocation-block)))

 (func $begin-relocate-blockstore (export "begin-relocate-blockstore")
   (param $page-count i32)

   (local $relocation-block i32)

   (call $set-blockstore-relocation-offset
         (i32.shl (local.get $page-count)
                  (global.get $page-size-bits)))

   (local.set $relocation-block (call $make-relocation-block))

   (call $set-blockstore-relocation-block (local.get $relocation-block))
   (call $set-blockstore-free-area (call $get-next-block (local.get $relocation-block)))

   (call $set-blockstore-current-relocation
         (i32.sub (call $get-next-block (local.get $relocation-block))
                  (global.get $value-size))))

 (func $step-relocate-blockstore (export "step-relocate-blockstore")

   (local $block i32)
   (local $block-owner i32)
   (local $block-ref i32)
   (local $next-free-block i32)
   (local $offset i32)
   (local $relocated-block i32)

   (local.set $block-ref (call $get-blockstore-current-relocation))

   (local.set $block (i32.load (local.get $block-ref)))

   (local.set $offset (call $get-blockstore-relocation-offset))

   (local.set $relocated-block (i32.add (local.get $block) (local.get $offset)))

   (local.set $block-owner (call $get-block-owner (local.get $block)))

   (if (i32.ne (local.get $block-owner) (global.get $null))
       (then
        (call $set-blockvalue-block
              (local.get $block-owner)
              (local.get $relocated-block)))
     (else
      (local.set $next-free-block (call $get-next-free-block (local.get $block)))
      (if (i32.ne (local.get $next-free-block) (global.get $null))
          (then
           (call $set-next-free-block
                 (local.get $block)
                 (i32.add (local.get $next-free-block)
                          (local.get $offset)))))))

   (memory.copy (local.get $relocated-block)
                (local.get $block)
                (call $get-block-size (local.get $block)))

   (call $set-blockstore-current-relocation
         (i32.sub (local.get $block-ref)
                  (global.get $value-size))))

 (func $end-relocate-blockstore (export "end-relocate-blockstore")

   (local $blockstore i32)
   (local $relocated-blockstore i32)
   (local $relocation-block i32)

   (local.set $blockstore (call $get-blockstore))
   (local.set $relocated-blockstore (i32.add (local.get $blockstore)
                                             (call $get-blockstore-relocation-offset)))

   (memory.copy (global.get $blockstore-header-size)
                (local.get $blockstore)
                (local.get $relocated-blockstore))

   (call $set-blockstore (local.get $relocated-blockstore))

   (local.set $relocation-block (call $get-blockstore-relocation-block))

   (call $set-blockstore-relocation-offset (i32.const 0))
   (call $set-blockstore-relocation-block (global.get $null))
   (call $set-blockstore-current-relocation (global.get $null))

   (call $dealloc-block (local.get $relocation-block)))


 )
