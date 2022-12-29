(module

 (import "memory" "main" (memory 1))

 (import "algorithms" "bisect-left-i64"
         (func $bisect-left-i64 (param i32 i32 i32)))

 (import "algorithms" "hoare-quicksort-i64"
         (func $hoare-quicksort-i64 (param i32 i32 i32)))

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

 (global $root-pair-flags                 (export "root-pair-flags")                 i32 (i32.const 0x00000008))
 (global $root-stale-pair-group-flags     (export "root-stale-pair-group-flags")     i32 (i32.const 0x00000010))
 (global $root-uncertain-pair-group-flags (export "root-uncertain-pair-group-flags") i32 (i32.const 0x00000018))

 ;; (global $root-z (export "root-z") i32 (i32.const 0))

 (global $sep-list              (export "ref-list")              (mut i32) (i32.const 0))
 (global $ref-list              (export "ref-list")              (mut i32) (i32.const 0))
 (global $ref-list-length       (export "ref-list-length")       (mut i32) (i32.const 0))
 (global $refindex-generations-list (export "refindex-generations-list") i32 (i32.const 0x0000))

 ;; Refindex

 (global $index-entry-size      (export "index-entry-size")      i32 (i32.const 8))
 (global $index-entry-length    (export "index-entry-length")    i32 (i32.const 2))

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

 (func $can-ref (export "can-ref")
   (param $value i32)
   (result i32)

   (local $tag i32)

   (local.set $tag (call $get-value-tag (local.get $value)))

   (i32.or (i32.eq (local.get $tag) (global.get $tag-block))
           (i32.or (i32.eq (local.get $tag) (global.get $tag-box))
                   (i32.eq (local.get $tag) (global.get $tag-pair)))))


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
 ;; Pair Flags Initialization
 ;;

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
