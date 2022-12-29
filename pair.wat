(module

 ;;=============================================================================
 ;;
 ;; Kernel
 ;;
 ;; Purpose: implement basic data representation
 ;;
 ;; Structure:
 ;;
 ;; Objects: pairs,

 (import "memory" "main" (memory 1))

 ;; Values
 ;;
 ;; Every location in memory must have an unambiguous interpretation, or be
 ;; unused.

 (global $value-size  (export "value-size")  i32 (i32.const 4))
 (global $pair-size   (export "pair-size")   i32 (i32.const 8))
 (global $page-size   (export "page-size")   i32 (i32.const 0x10000))

 (global $value-size-bits  (export "value-size-bits")  i32 (i32.const 2))
 (global $pair-size-bits   (export "pair-size-bits")   i32 (i32.const 3))
 (global $page-size-bits   (export "page-size-bits")   i32 (i32.const 16))

 ;;=============================================================================
 ;;
 ;; Pairs
 ;;
 ;; Pairs are the fundamental data type, from which values of all other types
 ;; are referenced.

 (global $initial-pairs-bottom (export "initial-pairs-bottom") i32 (i32.const 0x00000000))
 (global $initial-pairs-top    (export "initial-pairs-top")    i32 (i32.const 0x00010000))

 (global $pairs-bottom   (export "pairs-bottom")   (mut i32) (i32.const 0xffffffff))
 (global $pairs-top      (export "pairs-top")      (mut i32) (i32.const 0xffffffff))
 (global $pair-count     (export "pair-count")     (mut i32) (i32.const 0x00000000))
 (global $pair-free-list (export "pair-free-list") (mut i32) (i32.const 0xffffffff))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Initialization
 ;;

 (func $init-pairs (export "init-pairs")
   (param $bottom i32)
   (param $top i32)

   (global.set $pairs-bottom (local.get $bottom))
   (global.set $pairs-top (local.get $top))
   (global.set $pair-count (i32.const 0))
   (global.set $pair-free-list (global.get $null))

   (call $fill-pair-free-list (local.get $bottom) (local.get $top)))

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

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Accessors
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

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Allocation
 ;;

 (func $make-pair (export "make-pair")
   (param $car i32)
   (param $cdr i32)
   (result i32)

   (local $pair-addr i32)

   (local.set $pair-addr (call $alloc-pair))

   (call $set-pair-car (local.get $pair-addr) (local.get $car))
   (call $set-pair-car (local.get $pair-addr) (local.get $cdr))

   (local.get $pair-addr))

 (func $alloc-pair (export "alloc-pair")
   (result i32)

   (if (i32.eq (global.get $pair-free-list) (global.get $null))
       (then
        (call $expand-pair-storage)))

   (global.set $pair-count (i32.add (global.get $pair-count) (i32.const 1)))

   (global.get $pair-free-list)
   (global.set $pair-free-list (i32.load (global.get $pair-free-list))))

 (func $expand-pair-storage (export "expand-pair-storage")
   (if (i32.eq (global.get $pairs-top) (global.get $blocks-bottom))
       (then
        nop)) ;; TODO

   (call $fill-pair-free-list
         (global.get $pairs-top)
         (global.get $blocks-bottom))

   (global.set $pairs-top (global.get $blocks-bottom)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Deallocation
 ;;

 (func $dealloc-pair (export "dealloc-pair")
   (param $pair i32)

   (if (call $is-pair-block-owner (local.get $pair))
       (then
        (call $dealloc-block (call $get-pair-cdr (local.get $pair)))))

   (call $set-pair-car (local.get $pair) (global.get $pair-free-list))

   (global.set $pair-free-list (local.get $pair))

   (global.set $pair-count (i32.sub (global.get $pair-count) (i32.const 1))))

 (func $is-pair-block-owner (export "is-pair-block-owner")
   (param $pair i32)
   (result i32)
   (call $is-block-type (call $get-pair-car (local.get $pair))))

(func $is-block-type (export "is-block-type")
   (param $value i32)
   (result i32)
   (i32.eq (i32.and (local.get $value)
                    (global.get $singleton-type-mask))
           (global.get $singleton-type-block-type)))

 ;;-----------------------------------------------------------------------------
 ;;
 ;; Pair Interface Functions
 ;;
 ;; These functions comprise the external interface to pairs.

 (func $cons (export "cons")
   (param $car i32)
   (param $cdr i32)
   (result i32)

   (local $pair-addr i32)
   (local.set $pair-addr (call $make-pair (local.get $car) (local.get $cdr)))

   (call $add-ref (local.get $pair-addr) (local.get $car))
   (call $add-ref (local.get $pair-addr) (local.get $cdr))

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
 ;; Garbage Collection Interface
 ;;
 ;; Garbage collection can be provided by any module that implements `add-ref`
 ;; and `release` methods. They each take two parameters. The first is the pair
 ;; that will be/was referencing the value given as the second parameter.

 (table $gc-interface (export "gc-interface") (2 2) funcref)
 (global $gc-add-ref (export "gc-add-ref") i32 (i32.const 0))
 (global $gc-release (export "gc-release") i32 (i32.const 1))

 (type $gc-add-ref-sig (func (param i32 i32)))

 (func $add-ref (export "add-ref")
   (param $pair i32)
   (param $value i32)

   (call_indirect $gc-interface
                  (type $gc-add-ref-sig)
                  (global.get $gc-add-ref)
                  (local.get $pair)
                  (local.get $value)))

 (type $gc-release-sig (func (param i32 i32)))

 (func $release (export "release")
   (param $pair i32)
   (param $value i32)

   (call_indirect $gc-interface
                  (type $gc-release-sig)
                  (global.get $gc-release)
                  (local.get $pair)
                  (local.get $value)))

 ;; Explicit versus Procedural Memory Management
 ;;
 ;; Explicit memory management refers to the use of alloc and dealloc functions
 ;; by functions, modules, or subsystems for their own use. These pairs and
 ;; blocks are never directly exposed at the level of the programming language,
 ;; nor are they ever tracked by the garbage collector -- ie. they may never be
 ;; provided as arguments to add-ref or release.  The internal implementation is
 ;; responsible for tracking ownership of these objects and deallocating them when
 ;; they are no longer needed.
 ;;
 ;; Procedural memory management is done by the gc module. Objects that are
 ;; managed by gc should never refer to explicitly managed objects.



 )
