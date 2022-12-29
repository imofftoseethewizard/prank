(module
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

)
