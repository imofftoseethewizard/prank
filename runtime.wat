(module
 (memory (export "mem") 5)

 (type $lexical-rule-func (func (result i32)))

 (global $word-size i32 i32.const 4)

 (global $value-data-mask          i32 i32.const 0xfffffff0)
 (global $value-type-mask          i32 i32.const 0xf)
 (global $value-type-bits          i32 i32.const 4)

 (global $value-type-small-integer i32 i32.const 0x0)
 (global $value-type-pair          i32 i32.const 0x1)
 (global $value-type-vector        i32 i32.const 0x2)
 (global $value-type-character     i32 i32.const 0x3)
 (global $value-type-symbol        i32 i32.const 0x4)
 (global $value-type-singleton     i32 i32.const 0xf)

 (global $pair-next-free-id (mut i32) i32.const 0)
 (global $pair-size i32 i32.const 8)

 (global $vector-index          (mut i32) i32.const 0x10000)
 (global $vector-data           (mut i32) i32.const 0x11000)
 (global $vector-next-free-id   (mut i32) i32.const 0)
 (global $vector-next-free-data (mut i32) i32.const 0)
 (global $vector-max-id         (mut i32) i32.const 512)

 (global $vector-entry-size   (mut i32) i32.const 8)

 (global $symbol-index          (mut i32) i32.const 0x20000)
 (global $symbol-data           (mut i32) i32.const 0x21000)
 (global $symbol-next-free-id   (mut i32) i32.const 0)
 (global $symbol-next-free-data (mut i32) i32.const 0)
 (global $symbol-max-id         (mut i32) i32.const 512)

 (global $symbol-entry-size   (mut i32) i32.const 8)

 ;; singletons
 (global $eof   (export "EOF")   i32 i32.const 0xeee00fff)
 (global $false (export "FALSE") i32 i32.const 0x0000000f)
 (global $null  (export "NULL")  i32 i32.const 0xffffffff)
 (global $true  (export "TRUE")  i32 i32.const 0x0000001f)

 (global $input-buffer  (export "input_buffer")  i32 i32.const 0x30000)
 (global $output-buffer (export "output_buffer") i32 i32.const 0x34000)
 (global $error-buffer  (export "error_buffer")  i32 i32.const 0x38000)

 (global $input-buffer-size  (export "input_buffer_size")  i32 i32.const 0x4000)
 (global $output-buffer-size (export "output_buffer_size") i32 i32.const 0x4000)
 (global $error-buffer-size  (export "error_buffer_size")  i32 i32.const 0x4000)

 (data (offset (i32.const 0x40000)) "\05inf.0")
 (data (offset (i32.const 0x40006)) "\05nan.0")

 (global $static-string-inf i32 i32.const 0x40000)
 (global $static-string-nan i32 i32.const 0x40006)

 (global $input-length  (export "input_length")  (mut i32) i32.const 0)
 (global $output-length (export "output_length") (mut i32) i32.const 0)
 (global $error-length  (export "error_length")  (mut i32) i32.const 0)

 (global $input-point  (export "input_point")  (mut i32) i32.const 0)
 (global $output-point (export "output_point") (mut i32) i32.const 0)
 (global $error-point  (export "error_point")  (mut i32) i32.const 0)

 (global $token-type-open-paren  i32 i32.const 0)
 (global $token-type-close-paren i32 i32.const 1)
 (global $token-type-atom        i32 i32.const 2)
 (global $token-type-eof         i32 i32.const 3)

 (global $char-line-feed       i32 i32.const 10)
 (global $char-carriage-return i32 i32.const 13)
 (global $char-space           i32 i32.const 32)
 (global $char-double-quote    i32 i32.const 34)
 (global $char-hash-mark       i32 i32.const 35)
 (global $char-open-paren      i32 i32.const 40)
 (global $char-close-paren     i32 i32.const 41)
 (global $char-plus            i32 i32.const 43)
 (global $char-minus           i32 i32.const 45)
 (global $char-0               i32 i32.const 48)
 (global $char-1               i32 i32.const 49)
 (global $char-7               i32 i32.const 55)
 (global $char-9               i32 i32.const 57)
 (global $char-semicolon       i32 i32.const 59)
 (global $char-A               i32 i32.const 65)
 (global $char-F               i32 i32.const 70)
 (global $char-backslash       i32 i32.const 92)
 (global $char-a               i32 i32.const 97)
 (global $char-b               i32 i32.const 98)
 (global $char-d               i32 i32.const 100)
 (global $char-e               i32 i32.const 101)
 (global $char-f               i32 i32.const 102)
 (global $char-i               i32 i32.const 105)
 (global $char-o               i32 i32.const 111)
 (global $char-x               i32 i32.const 120)

 (global $error-code           (export "error-code") (mut i32) i32.const 0)
 (global $error-pair-expected  (export "error:pair-expected")  i32 i32.const 1)
 (global $error-unexpected-eof (export "error:unexpected-eof") i32 i32.const 2)

 (start $init)
 (func $init (export "init")
   i32.const 0
   i32.const 0xff
   i32.const 0xffff
   memory.fill)

 (func $string-eq (export "string_eq")
   (param $s-1 i32)
   (param $l-1 i32)
   (param $s-2 i32)
   (param $l-2 i32)
   (result i32)

   (local $_i i32)

   (local.set $_i (i32.const 0))

   (loop $again (result i32)

     (if (i32.or
          (i32.eq (local.get $l-1) (local.get $_i))
          (i32.eq (local.get $_i) (local.get $l-2)))
         (then
          (local.get $l-1)
          (local.get $l-2)
          (i32.eq)
          (return)))
     (if (i32.ne
          (i32.load8_u (local.get $s-1))
          (i32.load8_u (local.get $s-2)))
         (then
          (i32.const 0)
          (return)
          ))

     (local.set $_i (i32.add (local.get $_i) (i32.const 1)))
     (local.set $s-1 (i32.add (local.get $s-1) (i32.const 1)))
     (local.set $s-2 (i32.add (local.get $s-2) (i32.const 1)))

     (br $again)))

 (func $make-value (param i32 i32) (result i32)
   local.get 0
   global.get $value-type-bits
   i32.shl
   local.get 1
   i32.or)

 (func $value-type (param i32) (result i32)
   local.get 0
   global.get $value-type-mask
   i32.and)

 (func $value-data (param i32) (result i32)
   local.get 0
   global.get $value-data-mask
   i32.and
   global.get $value-type-bits
   i32.shr_u)

 (func $is-pair (export "is_pair") (param i32) (result i32)
   local.get 0
   call $value-type
   global.get $value-type-pair
   i32.eq
   if (result i32)
   global.get $true
   else
   global.get $false
   end)

 (func $assert (param i32 i32)
   local.get 0
   global.get $false
   i32.eq
   if
   local.get 1
   global.set $error-code
   unreachable
   end)

 (func $deref-pair (param i32) (result i32)
   local.get 0
   global.get $pair-size
   i32.mul)

 (func $pair-addr (param i32) (result i32)

   local.get 0
   call $is-pair
   global.get $error-pair-expected
   call $assert

   local.get 0
   call $value-data
   call $deref-pair)

 (func $next-pair-id (result i32)
   (local $new-pair-id i32)
   global.get $pair-next-free-id
   local.tee $new-pair-id

   i32.const 1
   i32.add
   global.set $pair-next-free-id

   local.get $new-pair-id)

 (func $pair (export "cons") (param i32 i32) (result i32)
   (local $new-pair-addr i32)
   (local $new-pair-id i32)

   call $next-pair-id
   local.tee $new-pair-id

   call $deref-pair
   local.tee $new-pair-addr

   local.get 0
   i32.store

   local.get $new-pair-addr
   global.get $word-size
   i32.add
   local.get 1
   i32.store

   local.get $new-pair-id
   global.get $value-type-pair
   call $make-value)

 (func $car (export "car") (param i32) (result i32)
   local.get 0
   call $pair-addr
   i32.load)

 (func $cdr (export "cdr") (param i32) (result i32)
   local.get 0
   call $pair-addr
   global.get $word-size
   i32.add
   i32.load)

 (func $deref-vector (param $id i32) (result i32)
   local.get $id
   global.get $vector-entry-size
   i32.mul

   global.get $vector-index
   i32.add)

 (func $next-vector-id (result i32)

   global.get $vector-next-free-id
   global.get $vector-next-free-id

   i32.const 1
   i32.add
   global.set $vector-next-free-id)

 (func $vector-alloc (param $size i32) (result i32)

   global.get $vector-next-free-data
   global.get $vector-next-free-data

   local.get $size
   i32.add
   global.set $vector-next-free-data

   global.get $word-size
   i32.mul

   global.get $vector-data
   i32.add)

 (func $fill-vector-elements
   (param $elems i32)
   (param $size i32)
   (param $value i32)


   (local $_elem i32)
   (local $_end i32)

   local.get $size
   global.get $word-size
   i32.mul

   local.get $elems
   local.tee $_elem
   i32.add
   local.set $_end

   loop $again

   local.get $_elem
   local.get $value
   i32.store

   local.get $_elem
   global.get $word-size
   i32.add
   local.tee $_elem

   local.get $_end
   i32.lt_u
   br_if $again

   end)

 (func $make-vector (export "make_vector")
   (param $size i32)
   (param $init-value i32)
   (result i32)

   (local $_id    i32)
   (local $_addr  i32)
   (local $_size  i32)
   (local $_elems i32)

   call $next-vector-id
   local.tee $_id

   call $deref-vector
   local.tee $_addr

   local.get $size
   call $vector-alloc
   local.tee $_elems

   ;; stores the vector address in the first word of the vector index record
   i32.store

   ;; compute address of the length field of the vector index record
   local.get $_addr
   global.get $word-size
   i32.add

   ;; store the vector length in the second word of the vector
   local.get $size
   i32.store

   local.get $_elems
   local.get $size
   local.get $init-value
   call $fill-vector-elements

   local.get $_id
   global.get $value-type-vector
   call $make-value)

 (func $vector-ref (export "vector_ref")
   (param $v i32)
   (param $i i32)
   (result i32)

   local.get $v
   call $deref-vector
   i32.load
   local.get $i
   global.get $word-size
   i32.mul
   i32.add
   i32.load)

 (func $vector-set (export "vector_set")
   (param $v i32)
   (param $i i32)
   (param $x i32)

   local.get $v
   call $deref-vector
   i32.load
   local.get $i
   global.get $word-size
   i32.mul
   i32.add
   local.get $x
   i32.store)

 (func $deref-symbol (param $id i32) (result i32)
   local.get $id
   global.get $symbol-entry-size
   i32.mul

   global.get $symbol-index
   i32.add)

 (func $symbol-name (export "symbol_name")
   (param $id i32)
   (result i32 i32)

   (local $_addr i32)

   local.get $id
   call $deref-symbol
   local.tee $_addr
   i32.load
   local.get $_addr
   global.get $word-size
   i32.add
   i32.load)

 (func $find-symbol (export "find_symbol")
   (param $str i32)
   (param $length i32)
   (result i32)

   (local $_id i32)

   i32.const 0
   local.set $_id

   loop $again (result i32)

   local.get $str
   local.get $length
   local.get $_id
   call $symbol-name
   call $string-eq
   if
   local.get $_id
   return
   end

   local.get $_id
   global.get $symbol-next-free-id
   i32.eq
   if
   i32.const -1
   return
   end

   local.get $_id
   i32.const 1
   i32.add
   local.set $_id
   br $again

   end)

 (func $next-symbol-id (result i32)

   global.get $symbol-next-free-id
   global.get $symbol-next-free-id

   i32.const 1
   i32.add
   global.set $symbol-next-free-id)

 (func $symbol-alloc (param $length i32) (result i32)

   global.get $symbol-next-free-data
   global.get $symbol-next-free-data

   local.get $length
   i32.add
   global.set $symbol-next-free-data

   global.get $symbol-data
   i32.add)

 (func $make-symbol (export "make_symbol")
   (param $str i32)
   (param $length i32)
   (result i32)

   (local $_id    i32)
   (local $_addr  i32)
   (local $_name  i32)

   call $next-symbol-id
   local.tee $_id

   call $deref-symbol
   local.tee $_addr

   local.get $length
   call $symbol-alloc
   local.tee $_name

   ;; stores the symbol name address in the first word of the symbol index record
   i32.store

   ;; compute address of the length field of the symbol index record
   local.get $_addr
   global.get $word-size
   i32.add

   ;; store the symbol length in the second word of the symbol
   local.get $length
   i32.store

   local.get $length
   local.get $str
   local.get $_name
   memory.copy

   local.get $_id
   global.get $value-type-symbol
   call $make-value)

 (func $inter-symbol (export "inter_symbol")
   (param $str i32)
   (param $length i32)
   (result i32)

   (local $_id i32)

   local.get $str
   local.get $length
   call $find-symbol

   local.tee $_id
   if
   local.get $_id
   return
   end

   local.get $str
   local.get $length
   call $make-symbol)

 (func $is-whitespace-char (param $c i32) (result i32)
   local.get $c
   global.get $char-space
   i32.le_u)

 (func $skip-whitespace
   loop $again
   call $is-at-eof
   if
   return
   end

   call $peek-char
   call $is-whitespace-char
   if
   call $advance-char
   br $again
   end
   end)

 (func $is-line-break-char (param $c i32) (result i32)
   local.get $c
   global.get $char-line-feed
   i32.eq
   local.get $c
   global.get $char-carriage-return
   i32.eq
   i32.or)

 (func $skip-comment

   call $is-at-eof
   if
   return
   end

   call $peek-char
   global.get $char-semicolon
   i32.eq
   if
   call $advance-char

   loop $again
   call $is-at-eof
   if
   return
   end

   call $peek-char
   call $is-line-break-char
   i32.eqz
   if
   call $advance-char
   br $again
   end
   end
   end)

 (func $skip-comments-and-whitespace

   (local $_c i32)

   loop $again
   call $is-at-eof
   if
   return
   end

   call $peek-char
   local.tee $_c
   call $is-whitespace-char
   if
   call $skip-whitespace
   br $again
   end

   local.get $_c
   global.get $char-semicolon
   i32.eq
   if
   call $skip-comment
   br $again
   end
   end)

 (func $is-at-eof (result i32)
   global.get $input-point
   global.get $input-length
   i32.eq)

 (func $advance-char
   (if (i32.lt_u (global.get $input-point) (global.get $input-length))
       (then
        (global.set $input-point (i32.add (global.get $input-point) (i32.const 1))))))

 (func $is-token-char (param $c i32) (result i32)
   local.get $c
   global.get $char-space
   i32.gt_u

   local.get $c
   global.get $char-open-paren
   i32.ne

   local.get $c
   global.get $char-close-paren
   i32.ne

   i32.and
   i32.and)

 (func $next-quoted-token (result i32 i32)
   (local $_c i32)

   loop $again
   call $next-char
   local.tee $_c
   global.get $char-double-quote
   i32.ne
   if
   local.get $_c
   global.get $char-backslash
   i32.eq
   if
   call $advance-char
   end

   br $again
   end
   end

   global.get $input-point
   global.get $token-type-atom)

 (func $next-simple-token (result i32 i32)

   loop $again
   call $peek-char
   call $is-token-char
   if
   call $advance-char
   call $is-at-eof
   i32.eqz
   if
   br $again
   end
   end
   end

   global.get $input-point
   global.get $token-type-atom)

 (func $next-delimiter-token
   (param $c i32)
   (result i32 i32)

   global.get $input-point
   local.get $c
   global.get $char-open-paren
   i32.eq
   if (result i32)
   global.get $token-type-open-paren
   else
   global.get $token-type-close-paren
   end)

 (func $next-token (export "next_token")
   (result i32 i32 i32)

   (local $_c i32)

   call $skip-comments-and-whitespace
   global.get $input-point

   call $is-at-eof
   if (result i32 i32)
   global.get $input-point
   global.get $token-type-eof

   else

   call $next-char
   local.tee $_c
   local.get $_c
   call $is-token-char
   if (param i32) (result i32 i32)
   global.get $char-double-quote
   i32.eq
   if (result i32 i32)
   call $next-quoted-token
   else
   call $next-simple-token
   end
   else
   call $next-delimiter-token
   end
   end)

 (func $next-char (result i32)
   (call $peek-char)
   (call $advance-char))

 (func $peek-char (result i32)
   (if (result i32) (i32.lt_u (global.get $input-point) (global.get $input-length))
     (then
      (i32.load8_u (i32.add (global.get $input-point) (global.get $input-buffer))))
     (else
      (global.get $eof))))

 (func $is-binary-digit (param $c i32) (result i32)
   (i32.or (i32.eq (local.get $c) (global.get $char-0))
           (i32.eq (local.get $c) (global.get $char-1))))

 (func $is-octal-digit (param $c i32) (result i32)
   (i32.and (i32.ge_u (local.get $c) (global.get $char-0))
            (i32.le_u (local.get $c) (global.get $char-7))))

 (func $is-decimal-digit (param $c i32) (result i32)
   (i32.and (i32.ge_u (local.get $c) (global.get $char-0))
            (i32.le_u (local.get $c) (global.get $char-9))))

 (func $is-hex-digit (param $c i32) (result i32)
   (i32.or (call $is-decimal-digit (local.get $c))
           (i32.or (i32.and (i32.ge_u (local.get $c) (global.get $char-A))
                            (i32.le_u (local.get $c) (global.get $char-F)))
                   (i32.and (i32.ge_u (local.get $c) (global.get $char-a))
                            (i32.le_u (local.get $c) (global.get $char-f))))))

 (func $try-rule (param $f (ref $lexical-rule-func)) (result i32)

   (local $_result i32)
   (local $_start i32)

   (local.set $_start (global.get $input-point))

   (if (result i32) (local.tee $_result (call_ref (local.get $f)))
     (then (local.get $_result))
     (else
      (global.set $input-point (local.get $_start))
      (i32.const 0))))

 (func $or-rules
   (param $r1 (ref $lexical-rule-func))
   (param $r2 (ref $lexical-rule-func))
   (result i32)

   (local $_result i32)

   (if (result i32) (local.tee $_result (call_ref (local.get $r1)))
     (then
      (local.get $_result))
     (else
      (call_ref (local.get $r2)))))

 (func $rule-digit-16 (type $lexical-rule-func)
   (if (result i32) (call $is-hex-digit (call $peek-char))
     (then
      (call $advance-char)
      (i32.const 1))
     (else (i32.const 0))))

 (func $rule-digit-10 (type $lexical-rule-func)
   (if (result i32) (call $is-decimal-digit (call $peek-char))
     (then
      (call $advance-char)
      (i32.const 1))
     (else (i32.const 0))))

 (func $rule-digit-8 (type $lexical-rule-func)
   (if (result i32) (call $is-octal-digit (call $peek-char))
     (then
      (call $advance-char)
      (i32.const 1))
     (else (i32.const 0))))

 (func $rule-digit-2 (type $lexical-rule-func)
   (if (result i32) (call $is-binary-digit (call $peek-char))
     (then
      (call $advance-char)
      (i32.const 1))
     (else (i32.const 0))))

 (func $_rule-radix-16 (type $lexical-rule-func)
   (if (result i32) (i32.eq (call $next-char) (global.get $char-hash-mark))
     (then (i32.eq (call $next-char) (global.get $char-x)))
     (else (i32.const 0))))

 (elem declare funcref (ref.func $_rule-radix-16))

 (func $rule-radix-16 (export "rule_radix_16") (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-radix-16)))

 (func $_rule-radix-10 (type $lexical-rule-func)
   (if (result i32) (i32.eq (call $next-char) (global.get $char-hash-mark))
     (then (i32.eq (call $next-char) (global.get $char-d)))
     (else (i32.const 0))))

 (elem declare funcref (ref.func $_rule-radix-10))

 (func $rule-radix-10 (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-radix-10)))

 (func $_rule-radix-8 (type $lexical-rule-func)
   (if (result i32) (i32.eq (call $next-char) (global.get $char-hash-mark))
     (then (i32.eq (call $next-char) (global.get $char-o)))
     (else (i32.const 0))))

 (elem declare funcref (ref.func $_rule-radix-8))

 (func $rule-radix-8 (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-radix-8)))

 (func $_rule-radix-2 (type $lexical-rule-func)
   (if (result i32) (i32.eq (call $next-char) (global.get $char-hash-mark))
     (then (i32.eq (call $next-char) (global.get $char-b)))
     (else (i32.const 0))))

 (elem declare funcref (ref.func $_rule-radix-2))

 (func $rule-radix-2 (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-radix-2)))

 (func $_rule-exactness (type $lexical-rule-func)
   (local $_c i32)

   (if (result i32) (i32.eq (call $next-char) (global.get $char-hash-mark))
     (then
      (i32.or
       (i32.eq
        (local.tee $_c (call $next-char))
        (global.get $char-e))
       (i32.eq
        (local.get $_c)
        (global.get $char-i))))
     (else
      (i32.const 0))))

 (elem declare funcref (ref.func $_rule-exactness))

 (func $rule-exactness (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-exactness)))

 (func $rule-sign (type $lexical-rule-func)
   (local $_c i32)

   (if (i32.or
        (i32.eq (local.tee $_c (call $peek-char)) (global.get $char-plus))
        (i32.eq (local.get $_c) (global.get $char-minus)))
       (then (call $advance-char)))

   (i32.const 1))

 (func $rule-exponent-marker (type $lexical-rule-func)

   (if (result i32) (i32.eq (call $peek-char) (global.get $char-e))
     (then
      (call $advance-char)
      (i32.const 1))
     (else (i32.const 0))))

 (func $_rule-suffix (type $lexical-rule-func)

   (if (call $rule-exponent-marker)
       (then
        (if (call $rule-sign)
            (then
             (if (call $rule-digit-10)
                 (then
                  (loop $again
                    (call $rule-digit-10)
                    (br_if $again))
                  (i32.const 1)
                  (return)))))))
   (i32.const 0))

 (elem declare funcref (ref.func $_rule-suffix))

 (func $rule-suffix (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-suffix)))

 (func $match-string-rule (param $s i32) (result i32)
   (local $_start i32)
   (local $_s i32)
   (local $_s-end i32)

   (local.set $_start (global.get $input-point))

   (local.set $_s (i32.add (local.get $s) (i32.const 1)))
   (local.set $_s-end (i32.add (local.get $s) (i32.load8_u (local.get $s))))

   (loop $again
     (if (i32.eq (call $next-char) (i32.load8_u (local.get $_s)))
         (then
          (if (i32.eq (local.get $_s) (local.get $_s-end))
              (then
               (i32.const 1)
               (return))
            (else
             (local.set $_s (i32.add (local.get $_s) (i32.const 1)))
             (br $again))))))

   (global.set $input-point (local.get $_start))
   (i32.const 0))

 (func $rule-inf (type $lexical-rule-func)
   (call $match-string-rule (global.get $static-string-inf)))

 (elem declare funcref (ref.func $rule-inf))

 (func $rule-nan (type $lexical-rule-func)
   (call $match-string-rule (global.get $static-string-nan)))

 (elem declare funcref (ref.func $rule-nan))

 (func $_rule-infnan (type $lexical-rule-func)

   (local $_c i32)

   (if (result i32)
       (i32.or
        (i32.eq (local.tee $_c (call $peek-char)) (global.get $char-plus))
        (i32.eq (local.get $_c) (global.get $char-minus)))
     (then
      (call $advance-char)
      (call $or-rules
            (ref.func $rule-inf)
            (ref.func $rule-nan)))
     (else
      (i32.const 0))))

 (elem declare funcref (ref.func $_rule-infnan))

 (func $rule-infnan (type $lexical-rule-func)
   (call $try-rule (ref.func $_rule-infnan)))

;;(func $prefix-2)

 )
