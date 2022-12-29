(module

 (import "memory" "main" (memory 1))

  (func $bisect-left-i64 (export "bisect-left-i64")
   (param $lo i32)
   (param $hi i32)
   (param $v i64)
   (result i32)

   (local $mid i32)

   (loop $again
     (local.set $mid (i32.and (i32.add (i32.shr_u (local.get $lo) (i32.const 1))
                                       (i32.shr_u (local.get $hi) (i32.const 1)))
                              (i32.const 0xfffffff8)))

     (if (i64.ge_u (local.get $v) (i64.load (local.get $mid)))
         (then
          (local.set $lo (local.get $mid)))
       (else
        (local.set $hi (local.get $mid))))
     (if (i32.lt_u (local.get $lo) (local.get $hi))
         (then
          (br $again))))

   (local.get $lo))

  (func $bisect-right-i64 (export "bisect-right-i64")
   (param $lo i32)
   (param $hi i32)
   (param $v i64)
   (result i32)

   (local $mid i32)

   (loop $again
     (local.set $mid (i32.and (i32.add (i32.shr_u (local.get $lo) (i32.const 1))
                                       (i32.shr_u (local.get $hi) (i32.const 1)))
                              (i32.const 0xfffffff8)))

     (if (i64.gt_u (local.get $v) (i64.load (local.get $mid)))
         (then
          (local.set $lo (local.get $mid)))
       (else
        (local.set $hi (local.get $mid))))
     (if (i32.lt_u (local.get $lo) (local.get $hi))
         (then
          (br $again))))

   (local.get $lo))

 (func $hoare-quicksort-i64 (export "hoare-quicksort-i64")
   (param $A i32)
   (param $lo i32)
   (param $hi i32)

   (local $p i32)

   (if (i32.and (i32.and (i32.ge_u (local.get $lo) (local.get $A))
                         (i32.ge_u (local.get $hi) (local.get $A)))
                (i32.lt_u (local.get $lo) (local.get $hi)))
       (then
        (local.set $p (call $hoare-partition-i64 (local.get $lo) (local.get $hi)))
        (call $hoare-quicksort-i64 (local.get $A) (local.get $lo) (local.get $p))
        (call $hoare-quicksort-i64
              (local.get $A)
              (i32.add (local.get $lo)
                       (i32.const 8))
              (local.get $hi)))))

 (func $hoare-partition-i64 (export "hoare-partition-i64")
   (param $lo i32)
   (param $hi i32)
   (result i32)

   (local $a i64)
   (local $b i64)
   (local $pivot i64)

   (local.set $pivot (i64.load
                      (i32.and (i32.add (i32.shr_u (local.get $lo) (i32.const 1))
                                        (i32.shr_u (local.get $hi) (i32.const 1)))
                               (i32.const 0xfffffff8))))

   (local.set $lo (i32.sub (local.get $lo) (i32.const 8)))
   (local.set $hi (i32.add (local.get $hi) (i32.const 8)))

   (loop $outer

     (loop $lo-inner
       (local.set $lo (i32.add (local.get $lo) (i32.const 8)))
       (local.set $a (i64.load (local.get $lo)))
       (if (i64.lt_u (local.get $a) (local.get $pivot))
           (then
            (br $lo-inner))))

     (loop $hi-inner
       (local.set $hi (i32.add (local.get $hi) (i32.const 8)))
       (local.set $b (i64.load (local.get $hi)))
       (if (i64.gt_u (local.get $b) (local.get $pivot))
           (then
            (br $hi-inner))))

     (if (i32.gt_u (local.get $lo) (local.get $hi))
         (then
          (i64.store (local.get $lo) (local.get $b))
          (i64.store (local.get $hi) (local.get $a))
          (br $outer))))

   (local.get $hi)))
