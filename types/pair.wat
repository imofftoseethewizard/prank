(module

 ;; Pairs
 ;;
 ;; Pairs are the fundamental data type, from which values of all other types
 ;; are referenced.

 (memory (export "memory") 2)

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

 (global $offset-size i32 (i32.const 2))
 (global $value-size i32 (i32.const 4))
 (global $pair-size i32 (i32.const 8))
 (global $block-size i32 (i32.const 8))

 ;; addresses in page 0
 (global $memory-page-count  i32 (i32.const 0x00000000))
 (global $memory-active-page i32 (i32.const 0x00000004))

 (global $page-flag-frontier-closed i32 (i32.const 0x0001))

 (global $page-flags                   i32 (i32.const 0x0000))
 (global $page-free-count              i32 (i32.const 0x0002))
 (global $page-free-scan-current-block i32 (i32.const 0x0004))
 (global $page-pair-bottom             i32 (i32.const 0x0008))
 (global $page-next-free-pair          i32 (i32.const 0x000c))
 (global $page-freelist-head           i32 (i32.const 0x0010))
 (global $page-freelist-start          i32 (i32.const 0x0014))
 (global $page-freelist-end            i32 (i32.const 0x0040))

 (global $page-free-scan-start-block   i32 (i32.const 0x0040))
 (global $page-free-scan-end-block     i32 (i32.const 0x03c8))

;; (global $page-free-scan-idx i32 (i32.const 0x0004))
;; (global $page-gc-scan-idx   i32 (i32.const 0x0008))

 (global $pair-flag-reachable i32 (i32.const 1))
 (global $pair-flag-pending   i32 (i32.const 2))
 (global $pair-flags-mask     i32 (i32.const 0x00000003))

 (global $pair-flag-reachable-i64-block i64 (i64.const 0x5555555555555555))
 (global $pair-flag-pending-i64-block   i64 (i64.const 0xaaaaaaaaaaaaaaaa))

 ;; The pair page base mask gives the base address of the page containing
 ;; a pair when the mask is applied to the pair value.
 (global $pair-page-base-mask i32 (i32.const 0xffff0000))

 ;; The pair page offset mask gives the offset from the page base to the
 ;; address of the values in the pair.
 (global $pair-page-offset-mask i32 (i32.const 0x0000fff8))

 ;; The pair flag address shift is the number of bit positions the pair addess
 ;; is shifted right to get the address of the byte containing the flag bits
 ;; for the pair in the containing page's memory map. Since the memory map
 ;; has two bits per 8 byte pair, the ratio of the first to the second is 1/32,
 ;; hence the shift is log2 32 = 5.
 (global $pair-flag-addr-shift i32 (i32.const 5))

 ;; The 5 lowest bits will be shifted out when the pair flag address shift
 ;; is applied. The three lower of these 5 bits will be zero, since pairs
 ;; are 8 bytes and 8 byte aligned. The upper two of those 5 bits provide
 ;; the index into the flag byte.
 (global $pair-flag-idx-mask i32 (i32.const 0x18))

 ;; The pair flag idx shift is the number of bit positions the pair address
 ;; is shifted right to get the index of the flag bits within the flag byte.
 ;; Since there are 2 bits per pair, there will be 4 sets of flag bits per
 ;; byte. Pair addresses that end with 0x8 should be mapped to bit position
 ;; 2, giving a shift of 2.
 (global $pair-flag-idx-shift  i32 (i32.const 2))

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

 ;; Pages

 ;; Memory page 0, the lowest 64KB, is used to manages pages 1 and up.

 (func $get-active-page (export "get-active-page")
   (result i32)
   (i32.load (global.get $memory-active-page)))

 (func $activate-next-page (export "activate-next-page")
   nop)

 (func $init-page (export "init-page")
   (param $page i32)

   (i32.store16
    (i32.const 0)
    (i32.add (local.get $page) (global.get $page-flags)))

   (i32.store16
    (i32.const 0xe0000)
    (i32.add (local.get $page) (global.get $page-free-count)))

   (i32.store
    (i32.add (local.get $page) (global.get $page-free-scan-start-block))
    (i32.add (local.get $page) (global.get $page-free-scan-current-block)))

   (i32.store
    (i32.add (local.get $page) (i32.const 0x0400))
    (i32.add (local.get $page) (global.get $page-pair-bottom)))

   (i32.store
    (i32.add (local.get $page) (i32.const 0xfff8))
    (i32.add (local.get $page) (global.get $page-next-free-pair)))

   (i32.store
    (i32.add  (local.get $page) (global.get $page-freelist-start))
    (i32.add (local.get $page) (global.get $page-freelist-head))))

 (start $init)
 (func $init
   (local $page i32)
   (local.set $page (i32.const 0x10000))
   (i32.store (local.get $page) (global.get $memory-active-page))
   (call $init-page (local.get $page)))

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

   (local.set $addr)
   (local.set $shift-count)

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
   (local $mask i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $addr)
   (local.set $shift-count)

   (local.set $mask (i32.shl (global.get $pair-flags-mask) (local.get $shift-count)))

   (i32.store8
    (i32.or
     (i32.and
      (i32.load8_u (local.get $addr))
      (i32.xor (local.get $mask) (i32.const -1)))
     (i32.and
      (i32.shl (local.get $flag) (local.get $shift-count))
      (local.get $mask)))
    (local.get $addr)))

(func $set-pair-flag (export "set-pair-flag")
  (param $pair i32)
  (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)
   (local $mask i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $addr)
   (local.set $shift-count)

   (local.set $mask (i32.shl (global.get $pair-flags-mask) (local.get $shift-count)))

   (i32.store8
    (i32.or
     (local.get $addr)
     (i32.shl (local.get $flag) (local.get $shift-count)))
    (local.get $addr)))

(func $clear-pair-flag (export "clear-pair-flag")
  (param $pair i32)
  (param $flag i32)

   (local $addr i32)
   (local $shift-count i32)
   (local $mask i32)

   (call $get-pair-flags-location (local.get $pair))

   (local.set $addr)
   (local.set $shift-count)

   (local.set $mask (i32.shl (global.get $pair-flags-mask) (local.get $shift-count)))

   (i32.store8
    (i32.and
     (local.get $addr)
     (i32.xor (i32.shl (local.get $flag) (local.get $shift-count)) (i32.const -1)))
    (local.get $addr)))

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

(func $page-decr-free-count (export "page-decr-free-count")
  (param $page i32)

  (local $free-count-addr i32)
  (local.set $free-count-addr (i32.add (local.get $page) (global.get $page-free-count)))

  (i32.store
   (i32.sub (i32.load (local.get $free-count-addr)) (i32.const 1))
   (local.get $free-count-addr)))

(func $fill-page-freelist-from-free-pair-map (export "fill-page-freelist-from-free-pair-map")
  (param $page i32)
  (param $block i32)
  (param $free-pair-map i64)

  (local $i i64)
  (local $pair-offset i32)
  (local $freelist-head i32)
  (local $freelist-end i32)

  (local.set $freelist-head (i32.add (local.get $page) (global.get $page-freelist-start)))
  (local.set $freelist-end (i32.add (local.get $page) (global.get $page-freelist-end)))

  ;; The flags map has 2 bits per 8 byte pair, so to translate the block address to the address
  ;; of the pairs it pertains to, the address needs to be shifted left 5 bit positions,
  ;; corresponding to the ratio of 2 bits to 8 bytes.

  (local.set $pair-offset (i32.and
                           (global.get $pair-page-offset-mask)
                           (i32.shl (local.get $block) (global.get $pair-flag-addr-shift))))


  (loop $again
    (local.set $i (i64.ctz (local.get $free-pair-map)))

    ;; shift the free pair map right by $i + 1 to move the zeros and the on bit out of the map
    (local.set $free-pair-map (i64.shr_u (local.get $free-pair-map)
                                         (i64.add (i64.const 1) (local.get $i))))

    ;; $i will be an odd number, where 1 corresponds to the first pair in the block, 3, the second. Hence
    ;; 1 -> 0, 3 -> 8, 5 -> 16 => (i - 1) * 4 gives the desired value
    (local.set $pair-offset
               (i32.add (local.get $pair-offset)
                        (i32.mul (i32.const 4)
                                 (i32.sub (i32.wrap_i64 (local.get $i))
                                          (i32.const 1)))))

    (i32.store16 (local.get $pair-offset) (local.get $freelist-head))

    (if (i32.and
         (i64.ne (local.get $free-pair-map) (i64.const 0))
         (i32.lt_u (local.get $freelist-head) (local.get $freelist-end)))
        (then
         (local.set $freelist-head (i32.add (local.get $freelist-head) (global.get $offset-size)))
         (br $again)))))

(func $get-block-free-pair-map (export "get-block-free-pair-map")
  (param $flag-block i64)
  (result i64)

  (i64.xor (global.get $pair-flag-pending-i64-block)
           (i64.or
            (i64.shl (i64.and (global.get $pair-flag-reachable-i64-block) (local.get $flag-block)) (i64.const 1))
            (i64.and (global.get $pair-flag-pending-i64-block) (local.get $flag-block)))))

(func $fill-page-freelist (export "fill-page-freelist")
  (param $page i32)

  (local $current-block-addr i32)
  (local $current-block i32)
  (local $end-block i32)
  (local $free-pair-map i64)

  (local.set $current-block-addr (i32.add (local.get $page) (global.get $page-free-scan-current-block)))
  (local.set $current-block (i32.load (local.get $current-block-addr)))
  (local.set $end-block (i32.add (local.get $page) (global.get $page-free-scan-end-block)))

  (loop $again
    (local.set $free-pair-map (call $get-block-free-pair-map (i64.load (local.get $current-block))))
    (if (i64.eqz (local.get $free-pair-map))
        (then
         (if (i32.eq (local.get $current-block) (local.get $end-block))
             (then (call $activate-next-page))
           (else
            (local.set $current-block (i32.add (local.get $current-block) (global.get $block-size)))
            (i32.store (local.get $current-block) (local.get $current-block-addr))
            (br $again))))
      (else
       (call $fill-page-freelist-from-free-pair-map
             (local.get $page)
             (local.get $current-block)
             (local.get $free-pair-map))))))

(func $page-alloc-freelist-pair (export "page-alloc-freelist-pair")
  (param $page i32)
  (result i32)

  (local $freelist-head-addr i32)
  (local $freelist-head i32)
  (local $new-pair i32)

  (local.set $freelist-head-addr (i32.add (local.get $page) (global.get $page-freelist-head)))
  (local.set $freelist-head (i32.load (local.get $freelist-head-addr)))
  (local.set $new-pair (i32.add (local.get $page) (i32.load16_u (local.get $freelist-head))))

  (call $mark-pair-dirty (local.get $new-pair))
  (call $page-decr-free-count (local.get $page))

  (local.set $freelist-head (i32.add (local.get $freelist-head) (global.get $offset-size)))

  (if (i32.eq (local.get $freelist-head)
              (i32.load (i32.add (local.get $page) (global.get $page-freelist-end))))
      (then
       (call $fill-page-freelist (local.get $page)))
    (else
     (i32.store (local.get $freelist-head) (local.get $freelist-head-addr))))

  (local.get $new-pair))

(func $page-frontier-closed? (export "page-frontier-closed?")
  (param $page i32)
  (result i32)

  (local $flags-addr i32)
  (local.set $flags-addr (i32.add (local.get $page) (global.get $page-flags)))
  (i32.or (global.get $page-flag-frontier-closed) (i32.load16_u (local.get $flags-addr))))

(func $close-page-frontier (export "close-page-frontier")
  (param $page i32)

  (local $flags-addr i32)
  (local.set $flags-addr (i32.add (local.get $page) (global.get $page-flags)))

  (i32.store16
   (i32.or (global.get $page-flag-frontier-closed) (i32.load (local.get $flags-addr)))
   (local.get $flags-addr))

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
     (i32.store (local.get $next-free-pair) (local.get $next-free-pair-addr))))

  (local.get $new-pair))

(func $alloc-pair (export "alloc-pair")
  (result i32)

  (local $page i32)
  (local.set $page (call $get-active-page))

  (if (result i32) (call $page-frontier-closed? (local.get $page))
    (then (call $page-alloc-freelist-pair (local.get $page)))
    (else (call $page-alloc-frontier-pair (local.get $page)))))

(func $make-pair (export "make-pair")
  (param $car i32)
  (param $cdr i32)
  (result i32)

  (local $pair-addr i32)
  (local.set $pair-addr (call $alloc-pair))

  (i32.store (local.get $car) (local.get $pair-addr))
  (i32.store (local.get $cdr) (i32.add (local.get $pair-addr) (global.get $value-size)))

  (i32.or (local.get $pair-addr) (global.get $tag-pair)))

)
