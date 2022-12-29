(module
 (memory (export "memory") 6)

 (global $page-size (export "page-size") i32 (i32.const 0x10000))

 ;;=============================================================================
 ;;
 ;; Block values
 ;;
 ;; Block values are pairs which serve as the fixed reference point of a block.
 ;; A block can be relocated, but pairs cannot, so these are stable addresses.
 ;; Each block that is referenced in a procedurally managed pair must have
 ;; exactly one block value associated with it.  Since blocks are used to
 ;; represent bytearrays, strings, and vectors, the value used to represent them
 ;; in pairs is a the block-tagged address of the corresponding block value.
 ;;
 ;; For example, a one element list referencing a string in its car would have
 ;; the following structure in memory:
 ;;
 ;;     pair addr: ( <block value addr | $tag-block > . $null )
 ;;
 ;;     block value addr: ( $type-string . < block addr > )
 ;;
 ;;     block addr:
 ;;       < block value addr >
 ;;       < length of block in values >
 ;;       < length of string in bytes >
 ;;       < bytes ... >
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
 ;; Block Accessors
 ;;

 (global $initial-blocks-bottom (export "initial-blocks-bottom") i32 (i32.const 0x00010000))
 (global $initial-blocks-top    (export "initial-blocks-top")    i32 (i32.const 0x00020000))

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

 ;;
 (global $root-block-free-list            (export "root-block-free-list")            i32 (i32.const 0x00000000))

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

 (func $dealloc-vector (export "dealloc-vector")
   (param $vector i32)
   (call $dealloc-block-value (local.get $vector)))

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


 ;;=============================================================================
 ;;
 ;; Bytearrays
 ;;

 ;;=============================================================================
 ;;
 ;; Strings
 ;;

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

 )