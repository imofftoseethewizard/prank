(module

 ;; Pairs
 ;;
 ;; Pairs are the fundamental data type, from which values of all other types
 ;; are referenced.

 (memory (export "memory") 1)

 ;; Memory
 ;;
 ;; Pair memory is organized into 64KB pages, where the bottom 2KB is reserved
 ;; for memory management. The lowest page also includes information about
 ;; the state of all pages, and the garbage collection process.
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
 (global $block-size  (export "block-size")  i32 (i32.const 8))
 (global $page-size   (export "page-size")   i32 (i32.const 0x10000))

 ;; addresses in page 0
 (global $memory-page-count  (export "memory-page-count")  i32 (i32.const 0x00000000))
 (global $memory-active-page (export "memory-active-page") i32 (i32.const 0x00000002))

 (global $page-flags                   (export "page-flags")                   i32 (i32.const 0x0000))
 (global $page-free-count              (export "page-free-count")              i32 (i32.const 0x0002))
 (global $page-free-scan-current-block (export "page-free-scan-current-block") i32 (i32.const 0x0004))
 (global $page-pair-bottom             (export "page-pair-bottom")             i32 (i32.const 0x0008))
 (global $page-next-free-pair          (export "page-next-free-pair")          i32 (i32.const 0x000c))
 (global $page-freelist-head           (export "page-freelist-head")           i32 (i32.const 0x0010))

 ;; The freelist is a top down stack of free cells located in batches after the page frontier
 ;; has closed. When the freelist is empty, the value at page+page-freelist-head will be
 ;; page+page-freelist-top. When it is full, it will be page+page-freelist-bottom.
 (global $page-freelist-bottom         (export "page-freelist-bottom")         i32 (i32.const 0x0014))
 (global $page-freelist-top            (export "page-freelist-top")            i32 (i32.const 0x0040))

 (global $page-flag-frontier-closed    (export "page-flag-frontier-closed")    i32 (i32.const 0x0001))

 (global $page-pair-flags-area         (export "page-pair-flags-area")         i32 (i32.const 0x0040))
 (global $page-pair-flags-byte-length  (export "page-pair-flags-byte-length")  i32 (i32.const 0x07c0))
 (global $page-initial-bottom          (export "page-initial-bottom")          i32 (i32.const 0x0800))
 (global $page-free-scan-end-block     (export "page-free-scan-end-block")     i32 (i32.const 0x07c8))
 (global $page-initial-free-count      (export "page-initial-free-count")      i32 (i32.const 0x1f00))
 (global $page-offset-mask             (export "page-offset-mask")             i32 (i32.const 0x0000ffff))

 ;; reserve 2K for the management area

 (global $pair-flag-reachable (export "pair-flag-reachable") i32 (i32.const 1))
 (global $pair-flag-pending   (export "pair-flag-pending")   i32 (i32.const 2))
 (global $pair-flags-mask     (export "pair-flags-mask")     i32 (i32.const 0x00000003))

 (global $pair-flag-reachable-i64-block i64 (i64.const 0x5555555555555555))
 (global $pair-flag-pending-i64-block   i64 (i64.const 0xaaaaaaaaaaaaaaaa))

 ;; The pair page base mask gives the base address of the page containing
 ;; a pair when the mask is applied to the pair value.
 (global $pair-page-base-mask (export "pair-flag-reachable-i64-block") i32 (i32.const 0xffff0000))

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

 (global $tag-small-mask    (export "tag-small-mask")    i32 (i32.const 0x07))
 (global $tag-mask          (export "tag-mask")          i32 (i32.const 0x1f))

 (global $tag-small-integer (export "tag-small-integer") i32 (i32.const 0x00))
 (global $tag-char          (export "tag-char")          i32 (i32.const 0x01))
 (global $tag-pair          (export "tag-pair")          i32 (i32.const 0x02))
 (global $tag-port          (export "tag-port")          i32 (i32.const 0x03))
 (global $tag-procedure     (export "tag-procedure")     i32 (i32.const 0x04))
 (global $tag-symbol        (export "tag-symbol")        i32 (i32.const 0x05))
 (global $tag-vector        (export "tag-vector")        i32 (i32.const 0x06))

 (global $tag-extended      (export "tag-extended")      i32 (i32.const 0x07))
 (global $tag-number        (export "tag-number")        i32 (i32.const 0x07))
 (global $tag-string        (export "tag-string")        i32 (i32.const 0x0f))
 (global $tag-bytevector    (export "tag-bytevector")    i32 (i32.const 0x17))
 (global $tag-singleton     (export "tag-singleton")     i32 (i32.const 0x1f))

 ;; singletons
 (global $eof   (export "#eof-object") i32 (i32.const 0xeee00fff))
 (global $false (export "#false")      i32 (i32.const 0x0000001f))
 (global $null  (export "#null")       i32 (i32.const 0xffffffff))
 (global $true  (export "#true")       i32 (i32.const 0x0000003f))

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

   (local $tag i32)
   (local.set $tag (i32.and (local.get $value) (global.get $tag-small-mask)))

   (if (result i32) (i32.eq (local.get $tag) (global.get $tag-extended))
     (then
      (i32.and (local.get $value) (global.get $tag-mask)))
     (else
      (local.get $tag))))

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
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-reachable)))

 (func $mark-pair-dirty (export "mark-pair-dirty")
   (param $pair i32)
   (call $set-pair-flag (local.get $pair) (global.get $pair-flag-pending)))

 (func $mark-pair-scanned (export "mark-pair-scanned")
   (param $pair i32)
   (call $clear-pair-flag (local.get $pair) (global.get $pair-flag-pending)))

 (func $mark-vector-reachable (export "mark-vector-reachable")
   (param $vector i32)

   (local $addr i32)
   (local $current-pair i32)
   (local $length i32)
   (local $end-pair i32)

   (call $set-all-pair-flags (local.get $vector) (global.get $pair-flag-reachable))

   ;; clear tag bits to convert vector to a pair address
   (local.set $addr (i32.and (local.get $vector) (i32.xor (global.get $tag-small-mask) (i32.const -1))))

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

 (func $scan-value (export "scan-value")
   (param $value i32)

   (local $tag i32)
   (local.set $tag (call $value-tag (local.get $value)))

   (if (result) (i32.eq (local.get  $tag) (global.get $tag-pair))
     (then (call $mark-pair-reachable (local.get $value)))
     (else
      (if (result) (i32.eq (local.get $tag) (global.get $tag-vector))
        (then (call $mark-vector-reachable (local.get $value)))))))

 (func $scan-pair (export "scan-pair")
   (param $pair i32)

   (local $addr i32)

   (local.set $addr (i32.xor (global.get $tag-small-mask) (i32.const -1)) (i32.and (local.get $pair)))

   (call $scan-value (i32.load (local.get $addr)))
   (call $scan-value (i32.load (i32.add (local.get $addr) (global.get $value-size))))

   (call $mark-pair-scanned (local.get $pair)))

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
   (param $block i32)
   (param $free-pair-map i64)

   (local $freelist-head-addr i32)
   (local $freelist-head i32)
   (local $freelist-bottom i32)

   (local $i i64)
   (local $pair-offset i32)

   (local.set $freelist-head-addr (i32.add (local.get $page) (global.get $page-freelist-head)))
   (local.set $freelist-head (i32.load (local.get $freelist-head-addr)))
   (local.set $freelist-bottom (i32.add (local.get $page) (global.get $page-freelist-bottom)))

   ;; The flags map has 2 bits per 8 byte pair, so to translate the block address to the address
   ;; of the pairs it pertains to, the address needs to be shifted left 5 bit positions (x32),
   ;; corresponding to the ratio of 2 bits to 8 bytes (2 to 64).

   (local.set $pair-offset (i32.and
                            (global.get $pair-page-offset-mask)
                            (i32.shl (local.get $block) (global.get $pair-flag-addr-shift))))

   (loop $again
     (if (i32.and
          (i64.ne (local.get $free-pair-map) (i64.const 0))
          (i32.gt_u (local.get $freelist-head) (local.get $freelist-bottom)))
         (then

          (local.set $freelist-head (i32.sub (local.get $freelist-head) (global.get $offset-size)))

          (local.set $i (i64.ctz (local.get $free-pair-map)))

          (local.set $free-pair-map
                     (if (result i64) (i64.lt_u (local.get $i) (i64.const 62))
                       (then
                        ;; shift the free pair map right by $i + 2 to consume the trailing
                        ;; zeros, the lowest set bit, and the zero immediately above it
                        (i64.shr_u (local.get $free-pair-map)
                                   (i64.add (i64.const 2) (local.get $i))))

                       (else
                        ;; if $i == 62, then it's a block with just the high pair free. In that
                        ;; case, the shr_u of 62+2 becomes a nop, and bad things happen.
                        (i64.const 0))))


          ;; $i will be an even number, where 0 corresponds to the first pair in the block, 2,
          ;; the second. Hence in terms of offsets, we have 0 -> 0, 2 -> 8, 4 -> 16 => i * 4
          ;; gives the desired value
          (local.set $pair-offset
                     (i32.add (local.get $pair-offset)
                              (i32.mul (i32.const 4)
                                       (i32.wrap_i64 (local.get $i)))))

          (i32.store16 (local.get $freelist-head) (local.get $pair-offset))

          ;; advance pair-offset to account for space used by the free pair just located
          (local.set $pair-offset (i32.add (local.get $pair-offset) (global.get $pair-size)))

          (br $again))))
   (i32.store (local.get $freelist-head-addr) (local.get $freelist-head)))

 (func $get-block-free-pair-map (export "get-block-free-pair-map")
   (param $flag-block i64)
   (result i64)

   (i64.xor (global.get $pair-flag-reachable-i64-block)
            (i64.or
             (i64.shr_u (i64.and (global.get $pair-flag-pending-i64-block) (local.get $flag-block)) (i64.const 1))
             (i64.and (global.get $pair-flag-reachable-i64-block) (local.get $flag-block)))))

 (func $fill-page-freelist (export "fill-page-freelist")
   (param $page i32)

   (local $current-block-addr i32)
   (local $current-block i32)
   (local $end-block i32)

   (local $freelist-head-addr i32)
   (local $freelist-bottom i32)
   (local $free-pair-map i64)

   (local.set $current-block-addr (i32.add (local.get $page) (global.get $page-free-scan-current-block)))
   (local.set $current-block (i32.load (local.get $current-block-addr)))
   (local.set $end-block (i32.add (local.get $page) (global.get $page-pair-flags-area)))

   (local.set $freelist-head-addr (i32.add (local.get $page) (global.get $page-freelist-head)))
   (local.set $freelist-bottom (i32.add (local.get $page) (global.get $page-freelist-bottom)))

   (loop $again
     (if (i32.and
          (i32.ge_u (local.get $current-block) (local.get $end-block))
          (i32.gt_u (i32.load (local.get $freelist-head-addr)) (local.get $freelist-bottom)))
         (then
          (local.set $free-pair-map (call $get-block-free-pair-map (i64.load (local.get $current-block))))
          (call $fill-page-freelist-from-free-pair-map
                (local.get $page)
                (local.get $current-block)
                (local.get $free-pair-map))
          (local.set $current-block (i32.sub (local.get $current-block) (global.get $block-size)))
          (br $again))))

   (i32.store (local.get $current-block-addr) (local.get $current-block)))

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

   (local.set $page (i32.mul (local.get $page-idx) (global.get $page-size)))
   (local.set $pair-flags-area (i32.add (local.get $page) (global.get $page-pair-flags-area)))

   (memory.fill
    (local.get $page)
    (i32.const 0)
    (global.get $page-initial-bottom))

   (i32.store16
    (i32.add (local.get $page) (global.get $page-free-count))
    (global.get $page-initial-free-count))

   (i32.store
    (i32.add (local.get $page) (global.get $page-free-scan-current-block))
    (i32.add (local.get $page)
             (i32.sub (global.get $page-initial-bottom)
                      (global.get $block-size))))

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
   (call $activate-next-page)))
