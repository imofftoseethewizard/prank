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



 )
