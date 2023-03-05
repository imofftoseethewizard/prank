(module
 (memory (export "mem") 5)

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

 (data (offset (i32.const 0x40000)) "\02#x")
 (data (offset (i32.const 0x40003)) "\02#d")
 (data (offset (i32.const 0x40006)) "\02#o")
 (data (offset (i32.const 0x40009)) "\02#b")
 (data (offset (i32.const 0x4000c)) "\02#e")
 (data (offset (i32.const 0x4000f)) "\02#i")
 (data (offset (i32.const 0x40012)) "\05inf.0")
 (data (offset (i32.const 0x40018)) "\05nan.0")
 (data (offset (i32.const 0x4001e)) "\05abnrt")
 (data (offset (i32.const 0x40024)) "\02\09 ") ;; tab and space
 (data (offset (i32.const 0x40027)) "\02\0d\0a") ;; cr lf -- both dos/windows line ending and line ending charset
 (data (offset (i32.const 0x4002a)) "\02\\x")
 (data (offset (i32.const 0x4002e)) "\02#t")
 (data (offset (i32.const 0x40031)) "\02#f")
 (data (offset (i32.const 0x40034)) "\05#true")
 (data (offset (i32.const 0x4003a)) "\06#false")
 (data (offset (i32.const 0x40041)) "\05alarm")
 (data (offset (i32.const 0x40047)) "\09backspace")
 (data (offset (i32.const 0x40051)) "\06delete")
 (data (offset (i32.const 0x40058)) "\06escape")
 (data (offset (i32.const 0x4005f)) "\07newline")
 (data (offset (i32.const 0x40067)) "\05null")
 (data (offset (i32.const 0x4006e)) "\06return")
 (data (offset (i32.const 0x40075)) "\05space")
 (data (offset (i32.const 0x4007b)) "\03tab")
 (data (offset (i32.const 0x4007f)) "\02#\\")
 (data (offset (i32.const 0x40082)) "\03#\\x")
 (data (offset (i32.const 0x40086)) "\0e!$%&*/:<=>?^_~")
 (data (offset (i32.const 0x40094)) "\02.@")
 (data (offset (i32.const 0x40097)) "\02#|")
 (data (offset (i32.const 0x4009a)) "\02|#")
 (data (offset (i32.const 0x4009d)) "\02#;")
 (data (offset (i32.const 0x400a0)) "\0a#!fold-case")
 (data (offset (i32.const 0x400aa)) "\0d#!no-fold-case")
 (data (offset (i32.const 0x400b8)) "\05|()\22\3b") ;; \22 is double-quote, \3b is semicolon
 (data (offset (i32.const 0x400be)) "\06()'`,.")
 (data (offset (i32.const 0x400c5)) "\02#(")
 (data (offset (i32.const 0x400c8)) "\04#u8(")
 (data (offset (i32.const 0x400cd)) "\02,@")

 (global $static-string-radix-16               i32 i32.const 0x40000)
 (global $static-string-radix-10               i32 i32.const 0x40003)
 (global $static-string-radix-8                i32 i32.const 0x40006)
 (global $static-string-radix-2                i32 i32.const 0x40009)
 (global $static-string-exact-prefix           i32 i32.const 0x4000c)
 (global $static-string-inexact-prefix         i32 i32.const 0x4000f)
 (global $static-string-inf                    i32 i32.const 0x40012)
 (global $static-string-nan                    i32 i32.const 0x40018)
 (global $static-string-mnemonic-escapes       i32 i32.const 0x4001e)
 (global $static-string-intraline-whitespace   i32 i32.const 0x4001e)
 (global $static-string-dos-line-ending        i32 i32.const 0x40027)
 (global $static-string-line-ending-charset    i32 i32.const 0x40027) ;; intentional duplication of previous
 (global $static-string-inline-escape-prefix   i32 i32.const 0x4002a)
 (global $static-string-boolean-t              i32 i32.const 0x4002e)
 (global $static-string-boolean-f              i32 i32.const 0x40031)
 (global $static-string-boolean-true           i32 i32.const 0x40034)
 (global $static-string-boolean-false          i32 i32.const 0x4003a)
 (global $static-string-alarm                  i32 i32.const 0x40041)
 (global $static-string-backspace              i32 i32.const 0x40047)
 (global $static-string-delete                 i32 i32.const 0x40051)
 (global $static-string-escape                 i32 i32.const 0x40058)
 (global $static-string-newline                i32 i32.const 0x4005f)
 (global $static-string-null                   i32 i32.const 0x40067)
 (global $static-string-return                 i32 i32.const 0x4006e)
 (global $static-string-space                  i32 i32.const 0x40075)
 (global $static-string-tab                    i32 i32.const 0x4007b)
 (global $static-string-character-prefix       i32 i32.const 0x4007f)
 (global $static-string-character-hex-prefix   i32 i32.const 0x40082)
 (global $static-string-special-initials       i32 i32.const 0x40086)
 (global $static-string-dot-and-at             i32 i32.const 0x40094)
 (global $static-string-begin-nested-comment   i32 i32.const 0x40097)
 (global $static-string-end-nested-comment     i32 i32.const 0x4009a)
 (global $static-string-begin-datum-comment    i32 i32.const 0x4009d)
 (global $static-string-directive-fold-case    i32 i32.const 0x400a0)
 (global $static-string-directive-no-fold-case i32 i32.const 0x400aa)
 (global $static-string-delimiter-charset      i32 i32.const 0x400b8)
 (global $static-string-token-charset          i32 i32.const 0x400be)
 (global $static-string-begin-syntax           i32 i32.const 0x400c5)
 (global $static-string-begin-bytevector       i32 i32.const 0x400c8)
 (global $static-string-unquote-splicing       i32 i32.const 0x400cd)

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
 (global $char-dot             i32 i32.const 46)
 (global $char-slash           i32 i32.const 47)
 (global $char-0               i32 i32.const 48)
 (global $char-1               i32 i32.const 49)
 (global $char-7               i32 i32.const 55)
 (global $char-9               i32 i32.const 57)
 (global $char-semicolon       i32 i32.const 59)
 (global $char-at-sign         i32 i32.const 64)
 (global $char-A               i32 i32.const 65)
 (global $char-F               i32 i32.const 70)
 (global $char-Z               i32 i32.const 90)
 (global $char-backslash       i32 i32.const 92)
 (global $char-a               i32 i32.const 97)
 (global $char-b               i32 i32.const 98)
 (global $char-d               i32 i32.const 100)
 (global $char-e               i32 i32.const 101)
 (global $char-f               i32 i32.const 102)
 (global $char-i               i32 i32.const 105)
 (global $char-o               i32 i32.const 111)
 (global $char-x               i32 i32.const 120)
 (global $char-z               i32 i32.const 123)
 (global $char-vertical-line   i32 i32.const 124)

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

   (local $i i32)

   (local.set $i (i32.const 0))

   (loop $again (result i32)

     (if (i32.or
          (i32.eq (local.get $l-1) (local.get $i))
          (i32.eq (local.get $i) (local.get $l-2)))
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
          (return)))

     (local.set $i (i32.add (local.get $i) (i32.const 1)))
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

 (func $ascii-lower
   (param $x i32)

   (result i32)

   (if (result i32)
       (i32.and
        (i32.ge_u (local.get $x) (global.get $char-A))
        (i32.le_u (local.get $x) (global.get $char-Z)))
     (then
      (i32.add (local.get $x) (i32.const 0x20)))
     (else
      (local.get $x))))

 (func $char-eq/ascii-ci
   (param $x i32)
   (param $y i32)

   (result i32)

   (i32.or
    (i32.eq (local.get $x) (local.get $y))
    (i32.eq (call $ascii-lower (local.get $x) (call $ascii-lower (local.get $y))))))

 (type $lexical-rule-func (func (param i32 i32 i32) (result i32 i32)))
 (table $lexical-rules 1 funcref)

 (func $lex-match-empty
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local.get $rule-id)
   (local.get $text))

 (func $lex-match-any-char
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local.get $rule-id)
   (if (result i32)
       (i32.eq (local.get $text) (local.get $end))
     (then
      (i32.const -1))
     (else
      (i32.add (i32.const 1) (local.get $text)))))

 (func $lex-match-char/ascii
   (param $rule-id i32)
   (param $char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (i32.const -1)
        (local.get $rule-id)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32) (i32.eq (local.get $char) (local.get $c))
     (then
      (i32.add (i32.const 1) (local.get $text))
      (local.get $rule-id))
     (else
      (i32.const -1)
      (local.get $rule-id))))

 (func $lex-match-char/ascii-ci
   (param $rule-id i32)
   (param $char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (i32.const -1)
        (local.get $rule-id)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32) (call $char-eq/ascii-ci (local.get $char) (local.get $c))
     (then
      (i32.add (i32.const 1) (local.get $text))
      (local.get $rule-id))
     (else
      (i32.const -1)
      (local.get $rule-id))))

 (func $lex-match-char-complement/ascii/set-of-2
   (param $rule-id i32)
   (param $first-char i32)
   (param $second-char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (i32.const -1)
        (local.get $rule-id)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32)
       (i32.and (i32.ne (local.get $first-char) (local.get $c))
                (i32.ne (local.get $second-char) (local.get $c)))
     (then
      (i32.add (i32.const 1) (local.get $text))
      (local.get $rule-id))
     (else
      (i32.const -1)
      (local.get $rule-id))))

 (func $lex-match-char-range/ascii
   (param $rule-id i32)
   (param $min-char i32)
   (param $max-char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (i32.const -1)
        (local.get $rule-id)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32)
       (i32.and
        (i32.ge_u (local.get $c) (local.get $min-char))
        (i32.le_u (local.get $c) (local.get $max-char)))
     (then
      (i32.add (i32.const 1) (local.get $text))
      (local.get $rule-id))
     (else
      (i32.const -1)
      (local.get $rule-id))))

 (func $match-charset
   (param $str i32)
   (param $length i32)
   (param $text i32)
   (param $end i32)

   (result i32)

   (local $c i32)
   (local $s i32)
   (local $s-end i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (i32.const -1)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (local.set $s (local.get $str))
   (local.set $s-end (i32.add (local.get $s) (local.get $length)))

   (loop $again
     (if (i32.lt_u (local.get $s) (local.get $s-end))
         (then
          (if (i32.eq (local.get $c) (i32.load8_u (local.get $s)))
              (then
               (i32.add (i32.const 1) (local.get $text))
               (return))
            (else
             (local.set $s (i32.add (local.get $s) (i32.const 1)))
             (br $again))))))

   (i32.const -1))

 (func $lex-match-charset
   (param $rule-id i32)
   (param $str i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local.get $rule-id)
   (call $match-charset
         (i32.add (i32.const 1) (local.get $str))
         (i32.load8_u (local.get $str))
         (local.get $text)
         (local.get $end)))

 (func $match-static-string
   (param $str i32)
   (param $length i32)
   (param $text i32)
   (param $end i32)

   (result i32)

   (local $s i32)
   (local $s-end i32)
   (local $t i32)

   (if (i32.gt_u (local.get $length) (i32.sub (local.get $end) (local.get $text)))
       (then
        (i32.const -1)
        (return)))

   (local.set $s (local.get $str))
   (local.set $s-end (i32.add (local.get $s) (local.get $length)))

   (local.set $t (local.get $text))

   (loop $again

     (if (i32.lt_u (local.get $s) (local.get $s-end))
         (then
          (if (i32.eq
               (i32.load8_u (local.get $s))
               (i32.load8_u (local.get $t)))
              (then
               (local.set $s (i32.add (local.get $s) (i32.const 1)))
               (local.set $t (i32.add (local.get $t) (i32.const 1)))
               (br $again))
            (else
             (local.set $t (i32.const -1)))))))

   (local.get $t))

 (func $lex-match-static-string
   (param $rule-id i32)
   (param $str i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local.get $rule-id)
   (call $match-static-string
         (i32.add (i32.const 1) (local.get $str))
         (i32.load8_u (local.get $str))
         (local.get $text)
         (local.get $end)))

 (func $match-static-string/ascii-ci
   (param $str i32)
   (param $length i32)
   (param $text i32)
   (param $end i32)

   (result i32)

   (local $s i32)
   (local $s-end i32)
   (local $t i32)

   (if (i32.gt_u (local.get $length) (i32.sub (local.get $end) (local.get $text)))
       (then
        (i32.const -1)
        (return)))

   (local.set $s (local.get $str))
   (local.set $s-end (i32.add (local.get $s) (local.get $length)))

   (local.set $t (local.get $text))

   (loop $again

     (if (i32.lt_u (local.get $s) (local.get $s-end))
         (then
          (if (call $char-eq/ascii-ci
                    (i32.load8_u (local.get $s))
                    (i32.load8_u (local.get $t)))
              (then
               (local.set $s (i32.add (local.get $s) (i32.const 1)))
               (local.set $t (i32.add (local.get $t) (i32.const 1)))
               (br $again))
            (else
             (local.set $t (i32.const -1)))))))

   (local.get $t))

 (func $lex-match-static-string/ascii-ci
   (param $rule-id i32)
   (param $str i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local.get $rule-id)
   (call $match-static-string/ascii-ci
         (i32.add (i32.const 1) (local.get $str))
         (i32.load8_u (local.get $str))
         (local.get $text)
         (local.get $end)))

 (func $lex-match-static-strings/longest-of-2
   (param $rule-id i32)
   (param $first-str i32)
   (param $second-str i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)
   (local $max-end i32)

   (local.set $max-end (i32.const -1))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $first-str))
                    (i32.load8_u (local.get $first-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $second-str))
                    (i32.load8_u (local.get $second-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.get $rule-id)
   (local.get $max-end))

 (func $lex-match-static-strings/longest-of-3
   (param $rule-id i32)
   (param $first-str i32)
   (param $second-str i32)
   (param $third-str i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)
   (local $max-end i32)

   (local.set $max-end (i32.const -1))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $first-str))
                    (i32.load8_u (local.get $first-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $second-str))
                    (i32.load8_u (local.get $second-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $third-str))
                    (i32.load8_u (local.get $third-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.get $rule-id)
   (local.get $max-end))

 (func $lex-match-static-strings/longest-of-4
   (param $rule-id i32)
   (param $first-str i32)
   (param $second-str i32)
   (param $third-str i32)
   (param $fourth-str i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)
   (local $max-end i32)

   (local.set $max-end (i32.const -1))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $first-str))
                    (i32.load8_u (local.get $first-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $second-str))
                    (i32.load8_u (local.get $second-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $third-str))
                    (i32.load8_u (local.get $third-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string
                    (i32.add (i32.const 1) (local.get $fourth-str))
                    (i32.load8_u (local.get $fourth-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.get $rule-id)
   (local.get $max-end))

 (func $lex-match-rule?
   (param $rule-id i32)
   (param $target-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $target-rule-id) (local.get $text) (local.get $end)
                  (local.get $target-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (result i32 i32) (i32.gt_s (local.get $end-match) (i32.const -1))
     (then
      (local.get $matching-rule-id)
      (local.get $end-match))
     (else
      (local.get $rule-id)
      (local.get $text))))

 (func $lex-match-rule/zero-or-more
   (param $rule-id i32)
   (param $target-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (local $next-matching-rule-id i32)
   (local $next-end i32)

   (local.set $matching-rule-id (local.get $rule-id))
   (local.set $end-match (local.get $text))

   (loop $again
     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $target-rule-id) (local.get $end-match) (local.get $end)
                    (local.get $target-rule-id))

     (local.set $next-matching-rule-id)
     (local.set $next-end)

     (if (i32.gt_s (local.get $next-end) (i32.const -1))
         (then
          (local.set $matching-rule-id (local.get $next-matching-rule-id))
          (local.set $end-match (local.get $next-end))
          (br $again))))

   (local.get $matching-rule-id)
   (local.get $end-match))

 (func $lex-match-rule/one-or-more
   (param $rule-id i32)
   (param $target-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (local $next-matching-rule-id i32)
   (local $next-end i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $target-rule-id) (local.get $text) (local.get $end)
                  (local.get $target-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (loop $again
     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $target-rule-id) (local.get $end-match) (local.get $end)
                    (local.get $target-rule-id))

     (local.set $next-matching-rule-id)
     (local.set $next-end)

     (if (i32.gt_s (local.get $next-end) (i32.const -1))
         (then
          (local.set $matching-rule-id (local.get $next-matching-rule-id))
          (local.set $end-match (local.get $next-end))
          (br $again))))

   (local.get $matching-rule-id)
   (local.get $end-match))

 (func $lex-match-rules/sequence
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $last-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $current-rule-id i32)
   (local $matching-rule-id i32)
   (local $end-match i32)

   (local.set $current-rule-id (local.get $first-rule-id))
   (local.set $matching-rule-id (local.get $rule-id))
   (local.set $end-match (local.get $text))

   (loop $again

     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $current-rule-id) (local.get $end-match) (local.get $end)
                    (local.get $current-rule-id))

     (local.set $matching-rule-id)
     (local.set $end-match)

     (if (i32.and
          (i32.gt_s (local.get $end-match) (i32.const -1))
          (i32.lt_u (local.get $current-rule-id) (local.get $last-rule-id)))
         (then
          (local.set $current-rule-id (i32.add (i32.const 1) (local.get $current-rule-id)))
          (br $again))))

   (if (result i32) (i32.gt_s (local.get $end-match) (i32.const -1))
     (then (local.get $matching-rule-id))
     (else (local.get $rule-id)))

   (local.get $end-match))

 (func $lex-match-rules/sequence-of-2
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $end-match) (local.get $end)
                  (local.get $second-rule-id)))

 (func $lex-match-rules/sequence-of-3
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $third-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $third-rule-id) (local.get $end-match) (local.get $end)
                  (local.get $third-rule-id)))

 (func $lex-match-rules/sequence-of-4
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $third-rule-id i32)
   (param $fourth-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $third-rule-id) (local.get $end-match) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.lt_s (local.get $end-match) (i32.const 0))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $fourth-rule-id) (local.get $end-match) (local.get $end)
                  (local.get $fourth-rule-id)))

 (func $lex-match-rules/longest
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $last-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $current-rule-id i32)
   (local $matching-rule-id i32)
   (local $end-match i32)

   (local $longest-matching-rule-id i32)
   (local $max-end i32)

   (local.set $current-rule-id (local.get $first-rule-id))
   (local.set $matching-rule-id (local.get $rule-id))
   (local.set $end-match (i32.const -1))

   (loop $again
     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $current-rule-id) (local.get $text) (local.get $end)
                    (local.get $current-rule-id))

     (local.set $matching-rule-id)
     (local.set $end-match)

     (if (i32.gt_s (local.get $end-match) (local.get $max-end))
         (then
          (local.set $longest-matching-rule-id (local.get $matching-rule-id))
          (local.set $max-end (local.get $end-match))))

     (if (i32.lt_u (local.get $current-rule-id) (local.get $last-rule-id))
         (then
          (local.set $current-rule-id (i32.add (i32.const 1) (local.get $current-rule-id)))
          (br $again))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/longest-of-2
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (local $longest-matching-rule-id i32)
   (local $max-end i32)

   (local.set $matching-rule-id (local.get $rule-id))
   (local.set $end-match (i32.const -1))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/longest-of-3
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $third-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (local $longest-matching-rule-id i32)
   (local $max-end i32)

   (local.set $matching-rule-id (local.get $rule-id))
   (local.set $end-match (i32.const -1))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $third-rule-id) (local.get $text) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/longest-of-4
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $third-rule-id i32)
   (param $fourth-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (local $longest-matching-rule-id i32)
   (local $max-end i32)

   (local.set $matching-rule-id (local.get $rule-id))
   (local.set $end-match (i32.const -1))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $third-rule-id) (local.get $text) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $fourth-rule-id) (local.get $text) (local.get $end)
                  (local.get $fourth-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/unordered-sequence-of-2
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (if (result i32 i32) (i32.ge_s (local.get $end-match) (i32.const 0))
     (then
      (call_indirect $lexical-rules (type $lexical-rule-func)
                     (local.get $second-rule-id) (local.get $end-match) (local.get $end)
                     (local.get $second-rule-id)))

     (else
      (call_indirect $lexical-rules (type $lexical-rule-func)
                     (local.get $second-rule-id) (local.get $text) (local.get $end)
                     (local.get $second-rule-id))

      (local.set $matching-rule-id)
      (local.set $end-match)

      (if (result i32 i32) (i32.ge_s (local.get $end-match) (i32.const 0))
        (then
         (call_indirect $lexical-rules (type $lexical-rule-func)
                        (local.get $first-rule-id) (local.get $end-match) (local.get $end)
                        (local.get $first-rule-id)))
        (else
         (local.get $rule-id)
         (i32.const -1))))))

 (func $lex-match-until-rule
   (param $rule-id i32)
   (param $end-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)

   (local $current i32)
   (local.set $current (local.get $text))

   (loop $again
     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $end-rule-id) (local.get $current) (local.get $end)
                    (local.get $end-rule-id))

     (drop) ;; matching rule id
     (local.set $end-match)

     (if (i32.eq (i32.const -1) (local.get $end-match))
         (then
          (local.set $current (i32.add (i32.const 1) (local.get $current)))
          (br $again))))

   (local.get $rule-id)
   (local.get $current))

 (func $lex-token-relabel
   (param $new-rule-id i32)
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $matching-rule-id i32)
   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $text) (local.get $end)
                  (local.get $rule-id))

   (local.set $matching-rule-id)
   (local.set $end-match)

   (local.get $new-rule-id)
   (local.get $end-match))

 (func $lex-match-digit-16/0-9
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (local.get $rule-id)
         (global.get $char-0)
         (global.get $char-9)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-16/0-9))
 (global $lex-rule-digit-16/0-9 i32 (i32.const 0))

 (func $lex-match-digit-16/A-F
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (local.get $rule-id)
         (global.get $char-A)
         (global.get $char-F)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-16/A-F))
 (global $lex-rule-digit-16/A-F i32 (i32.const 1))

 (func $lex-match-digit-16/a-f
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (local.get $rule-id)
         (global.get $char-a)
         (global.get $char-f)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-16/a-f))
 (global $lex-rule-digit-16/a-f i32 (i32.const 2))

 (func $lex-match-digit-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-digit-16)
         (global.get $lex-rule-digit-16/0-9)
         (global.get $lex-rule-digit-16/A-F)
         (global.get $lex-rule-digit-16/a-f)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-16))
 (global $lex-rule-digit-16 i32 (i32.const 3))

 (func $lex-match-digit-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (local.get $rule-id)
         (global.get $char-0)
         (global.get $char-9)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-10))
 (global $lex-rule-digit-10 i32 (i32.const 4))

 (func $lex-match-digit-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (local.get $rule-id)
         (global.get $char-0)
         (global.get $char-7)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-8))
 (global $lex-rule-digit-8 i32 (i32.const 5))

 (func $lex-match-digit-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (local.get $rule-id)
         (global.get $char-0)
         (global.get $char-1)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digit-2))
 (global $lex-rule-digit-2 i32 (i32.const 6))

 (func $lex-match-radix-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-radix-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-radix-16))
 (global $lex-rule-radix-16 i32 (i32.const 7))

 (func $lex-match-radix-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-radix-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-radix-10))
 (global $lex-rule-radix-10 i32 (i32.const 8))

 (func $lex-match-radix-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-radix-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-radix-8))
 (global $lex-rule-radix-8 i32 (i32.const 9))

 (func $lex-match-radix-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-radix-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-radix-2))
 (global $lex-rule-radix-2 i32 (i32.const 10))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-empty))
 (global $lex-rule-empty-prefix i32 (i32.const 11))

 (func $lex-match-exact-prefix
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-exact-prefix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-exact-prefix))
 (global $lex-rule-exact-prefix i32 (i32.const 12))

 (func $lex-match-inexact-prefix
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-inexact-prefix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-inexact-prefix))
 (global $lex-rule-inexact-prefix i32 (i32.const 13))

 (func $lex-match-exactness
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-exactness)
         (global.get $lex-rule-empty-prefix)
         (global.get $lex-rule-exact-prefix)
         (global.get $lex-rule-inexact-prefix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-exactness))
 (global $lex-rule-exactness i32 (i32.const 14))

 (func $lex-match-exponent-marker
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii-ci
         (global.get $lex-rule-exponent-marker)
         (global.get $char-e)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-exponent-marker))
 (global $lex-rule-exponent-marker i32 (i32.const 15))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-empty))
 (global $lex-rule-empty-sign i32 (i32.const 16))

 (func $lex-match-plus-sign
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii-ci
         (global.get $lex-rule-plus-sign)
         (global.get $char-plus)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-plus-sign))
 (global $lex-rule-plus-sign i32 (i32.const 17))

 (func $lex-match-minus-sign
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii-ci
         (global.get $lex-rule-minus-sign)
         (global.get $char-minus)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-minus-sign))
 (global $lex-rule-minus-sign i32 (i32.const 18))

 (func $lex-match-sign
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-sign)
         (global.get $lex-rule-empty-sign)
         (global.get $lex-rule-plus-sign)
         (global.get $lex-rule-minus-sign)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-sign))
 (global $lex-rule-sign i32 (i32.const 19))

 (func $lex-match-digits-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-digits-10)
         (global.get $lex-rule-digit-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digits-10))
 (global $lex-rule-digits-10 i32 (i32.const 20))

 (func $lex-match-suffix-sequence
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-suffix-sequence)
         (global.get $lex-rule-exponent-marker)
         (global.get $lex-rule-sign)
         (global.get $lex-rule-digits-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-suffix-sequence))
 (global $lex-rule-suffix-sequence i32 (i32.const 21))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-empty))
 (global $lex-rule-empty-suffix i32 (i32.const 22))

 (func $lex-match-suffix
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-suffix)
         (global.get $lex-rule-empty-suffix)
         (global.get $lex-rule-suffix-sequence)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-suffix))
 (global $lex-rule-suffix i32 (i32.const 23))

 (func $lex-match-explicit-sign
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-plus-sign)
         (global.get $lex-rule-minus-sign)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-explicit-sign))
 (global $lex-rule-explicit-sign i32 (i32.const 24))

 (func $lex-match-inf
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-inf)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-inf))
 (global $lex-rule-inf i32 (i32.const 25))

 (func $lex-match-nan
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (local.get $rule-id)
         (global.get $static-string-nan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-nan))
 (global $lex-rule-nan i32 (i32.const 26))

 (func $lex-match-inf-or-nan
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-inf-or-nan)
         (global.get $lex-rule-inf)
         (global.get $lex-rule-nan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-inf-or-nan))
 (global $lex-rule-inf-or-nan i32 (i32.const 27))

 (func $lex-match-infnan
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-inf-or-nan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-infnan))
 (global $lex-rule-infnan i32 (i32.const 28))

 (func $lex-match-prefix-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/unordered-sequence-of-2
         (global.get $lex-rule-prefix-16)
         (global.get $lex-rule-radix-16)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-prefix-16))
 (global $lex-rule-prefix-16 i32 (i32.const 29))

 (func $lex-match-prefix-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/unordered-sequence-of-2
         (global.get $lex-rule-prefix-10)
         (global.get $lex-rule-radix-10)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-prefix-10))
 (global $lex-rule-prefix-10 i32 (i32.const 30))

 (func $lex-match-prefix-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/unordered-sequence-of-2
         (global.get $lex-rule-prefix-8)
         (global.get $lex-rule-radix-8)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-prefix-8))
 (global $lex-rule-prefix-8 i32 (i32.const 31))

 (func $lex-match-prefix-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/unordered-sequence-of-2
         (global.get $lex-rule-prefix-2)
         (global.get $lex-rule-radix-2)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-prefix-2))
 (global $lex-rule-prefix-2 i32 (i32.const 32))

 (func $lex-match-uinteger-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-16)
         (global.get $lex-rule-digit-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-uinteger-16))
 (global $lex-rule-uinteger-16 i32 (i32.const 33))

 (func $lex-match-uinteger-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-10)
         (global.get $lex-rule-digit-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-uinteger-10))
 (global $lex-rule-uinteger-10 i32 (i32.const 34))

 (func $lex-match-uinteger-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-8)
         (global.get $lex-rule-digit-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-uinteger-8))
 (global $lex-rule-uinteger-8 i32 (i32.const 35))

 (func $lex-match-uinteger-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-2)
         (global.get $lex-rule-digit-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-uinteger-2))
 (global $lex-rule-uinteger-2 i32 (i32.const 36))

 (func $lex-match-dot
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-dot)
         (global.get $char-dot)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-dot))
 (global $lex-rule-dot i32 (i32.const 37))

 (func $lex-match-dot-digits-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-dot-digits-10)
         (global.get $lex-rule-dot)
         (global.get $lex-rule-digits-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-dot-digits-10))
 (global $lex-rule-dot-digits-10 i32 (i32.const 38))

 (func $lex-match-digits-10?
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-digits-10?)
         (global.get $lex-rule-digit-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digits-10?))
 (global $lex-rule-digits-10? i32 (i32.const 39))

 (func $lex-match-digits-dot-digits-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-digits-dot-digits-10)
         (global.get $lex-rule-digits-10)
         (global.get $lex-rule-dot)
         (global.get $lex-rule-digits-10?)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-digits-dot-digits-10))
 (global $lex-rule-digits-dot-digits-10 i32 (i32.const 40))

 (func $lex-match-decimal-10-forms
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-decimal-10-forms)
         (global.get $lex-rule-uinteger-10)
         (global.get $lex-rule-dot-digits-10)
         (global.get $lex-rule-digits-dot-digits-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-decimal-10-forms))
 (global $lex-rule-decimal-10-forms i32 (i32.const 41))

 (func $lex-match-decimal-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-decimal-10)
         (global.get $lex-rule-decimal-10-forms)
         (global.get $lex-rule-suffix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-decimal-10))
 (global $lex-rule-decimal-10 i32 (i32.const 42))

 (func $lex-match-slash
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-slash)
         (global.get $char-slash)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-slash))
 (global $lex-rule-slash i32 (i32.const 43))

 (func $lex-match-urational-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-urational-16)
         (global.get $lex-rule-uinteger-16)
         (global.get $lex-rule-slash)
         (global.get $lex-rule-uinteger-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-urational-16))
 (global $lex-rule-urational-16 i32 (i32.const 44))

 (func $lex-match-urational-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-urational-10)
         (global.get $lex-rule-uinteger-10)
         (global.get $lex-rule-slash)
         (global.get $lex-rule-uinteger-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-urational-10))
 (global $lex-rule-urational-10 i32 (i32.const 45))

 (func $lex-match-urational-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-urational-8)
         (global.get $lex-rule-uinteger-8)
         (global.get $lex-rule-slash)
         (global.get $lex-rule-uinteger-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-urational-8))
 (global $lex-rule-urational-8 i32 (i32.const 46))

 (func $lex-match-urational-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-urational-2)
         (global.get $lex-rule-uinteger-2)
         (global.get $lex-rule-slash)
         (global.get $lex-rule-uinteger-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-urational-2))
 (global $lex-rule-urational-2 i32 (i32.const 47))

 (func $lex-match-ureal-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-uinteger-16)
         (global.get $lex-rule-urational-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-ureal-16))
 (global $lex-rule-ureal-16 i32 (i32.const 48))

 (func $lex-match-ureal-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-uinteger-10)
         (global.get $lex-rule-urational-10)
         (global.get $lex-rule-decimal-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-ureal-10))
 (global $lex-rule-ureal-10 i32 (i32.const 49))

 (func $lex-match-ureal-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-uinteger-8)
         (global.get $lex-rule-urational-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-ureal-8))
 (global $lex-rule-ureal-8 i32 (i32.const 50))

 (func $lex-match-ureal-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-uinteger-2)
         (global.get $lex-rule-urational-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-ureal-2))
 (global $lex-rule-ureal-2 i32 (i32.const 51))

 (func $lex-match-signed-real-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-signed-real-16)
         (global.get $lex-rule-sign)
         (global.get $lex-rule-ureal-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-signed-real-16))
 (global $lex-rule-signed-real-16 i32 (i32.const 52))

 (func $lex-match-signed-real-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-signed-real-10)
         (global.get $lex-rule-sign)
         (global.get $lex-rule-ureal-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-signed-real-10))
 (global $lex-rule-signed-real-10 i32 (i32.const 53))

 (func $lex-match-signed-real-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-signed-real-8)
         (global.get $lex-rule-sign)
         (global.get $lex-rule-ureal-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-signed-real-8))
 (global $lex-rule-signed-real-8 i32 (i32.const 54))

 (func $lex-match-signed-real-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-signed-real-2)
         (global.get $lex-rule-sign)
         (global.get $lex-rule-ureal-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-signed-real-2))
 (global $lex-rule-signed-real-2 i32 (i32.const 55))

 (func $lex-match-real-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-real-16))
 (global $lex-rule-real-16 i32 (i32.const 56))

 (func $lex-match-real-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-real-10))
 (global $lex-rule-real-10 i32 (i32.const 57))

 (func $lex-match-real-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-real-8))
 (global $lex-rule-real-8 i32 (i32.const 58))

 (func $lex-match-real-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-real-2))
 (global $lex-rule-real-2 i32 (i32.const 59))

 (func $lex-match-at-sign
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-at-sign)
         (global.get $char-at-sign)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-at-sign))
 (global $lex-rule-at-sign i32 (i32.const 60))

 (func $lex-match-complex-polar-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-16)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-ureal-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-polar-16))
 (global $lex-rule-complex-polar-16 i32 (i32.const 61))

 (func $lex-match-complex-polar-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-10)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-ureal-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-polar-10))
 (global $lex-rule-complex-polar-10 i32 (i32.const 62))

 (func $lex-match-complex-polar-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-8)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-ureal-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-polar-8))
 (global $lex-rule-complex-polar-8 i32 (i32.const 63))

 (func $lex-match-complex-polar-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-2)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-ureal-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-polar-2))
 (global $lex-rule-complex-polar-2 i32 (i32.const 64))

 (func $lex-match-complex-i
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii-ci
         (global.get $lex-rule-complex-i)
         (global.get $char-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-i))
 (global $lex-rule-complex-i i32 (i32.const 65))

 (func $lex-match-complex-infnan-im-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-16)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-infnan-im-16))
 (global $lex-rule-complex-infnan-im-16 i32 (i32.const 66))

 (func $lex-match-complex-infnan-im-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-10)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-infnan-im-10))
 (global $lex-rule-complex-infnan-im-10 i32 (i32.const 67))

 (func $lex-match-complex-infnan-im-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-8)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-infnan-im-8))
 (global $lex-rule-complex-infnan-im-8 i32 (i32.const 68))

 (func $lex-match-complex-infnan-im-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-2)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-infnan-im-2))
 (global $lex-rule-complex-infnan-im-2 i32 (i32.const 69))

 (func $lex-match-full-complex-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-16)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-full-complex-16))
 (global $lex-rule-full-complex-16 i32 (i32.const 72))

 (func $lex-match-full-complex-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-10)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-full-complex-10))
 (global $lex-rule-full-complex-10 i32 (i32.const 72))

 (func $lex-match-full-complex-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-8)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-full-complex-8))
 (global $lex-rule-full-complex-8 i32 (i32.const 72))

 (func $lex-match-full-complex-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-2)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-full-complex-2))
 (global $lex-rule-full-complex-2 i32 (i32.const 72))

 (func $lex-match-complex-unit-im-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-16)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-unit-im-16))
 (global $lex-rule-complex-unit-im-16 i32 (i32.const 72))

 (func $lex-match-complex-unit-im-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-10)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-unit-im-10))
 (global $lex-rule-complex-unit-im-10 i32 (i32.const 72))

 (func $lex-match-complex-unit-im-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-8)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-unit-im-8))
 (global $lex-rule-complex-unit-im-8 i32 (i32.const 72))

 (func $lex-match-complex-unit-im-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-2)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-unit-im-2))
 (global $lex-rule-complex-unit-im-2 i32 (i32.const 72))

 (func $lex-match-complex-im-only-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-im-only-16)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-im-only-16))
 (global $lex-rule-complex-im-only-16 i32 (i32.const 70))

 (func $lex-match-complex-im-only-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-im-only-10)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-im-only-10))
 (global $lex-rule-complex-im-only-10 i32 (i32.const 71))

 (func $lex-match-complex-im-only-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-im-only-8)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-im-only-8))
 (global $lex-rule-complex-im-only-8 i32 (i32.const 72))

 (func $lex-match-complex-im-only-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-im-only-2)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-im-only-2))
 (global $lex-rule-complex-im-only-2 i32 (i32.const 73))

 (func $lex-match-complex-16/group-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-16/group-1)
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-complex-polar-16)
         (global.get $lex-rule-complex-infnan-im-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-16/group-1))
 (global $lex-rule-complex-16/group-1 i32 (i32.const 63))

 (func $lex-match-complex-10/group-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-10/group-1)
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-complex-polar-10)
         (global.get $lex-rule-complex-infnan-im-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-10/group-1))
 (global $lex-rule-complex-10/group-1 i32 (i32.const 63))

 (func $lex-match-complex-8/group-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-8/group-1)
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-complex-polar-8)
         (global.get $lex-rule-complex-infnan-im-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-8/group-1))
 (global $lex-rule-complex-8/group-1 i32 (i32.const 63))

 (func $lex-match-complex-2/group-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-2/group-1)
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-complex-polar-2)
         (global.get $lex-rule-complex-infnan-im-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-2/group-1))
 (global $lex-rule-complex-2/group-1 i32 (i32.const 63))

 (func $lex-match-complex-16/group-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-16/group-2)
         (global.get $lex-rule-full-complex-16)
         (global.get $lex-rule-complex-unit-im-16)
         (global.get $lex-rule-complex-im-only-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-16/group-2))
 (global $lex-rule-complex-16/group-2 i32 (i32.const 63))

 (func $lex-match-complex-10/group-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-10/group-2)
         (global.get $lex-rule-full-complex-10)
         (global.get $lex-rule-complex-unit-im-10)
         (global.get $lex-rule-complex-im-only-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-10/group-2))
 (global $lex-rule-complex-10/group-2 i32 (i32.const 63))

 (func $lex-match-complex-8/group-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-8/group-2)
         (global.get $lex-rule-full-complex-8)
         (global.get $lex-rule-complex-unit-im-8)
         (global.get $lex-rule-complex-im-only-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-8/group-2))
 (global $lex-rule-complex-8/group-2 i32 (i32.const 63))

 (func $lex-match-complex-2/group-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-2/group-2)
         (global.get $lex-rule-full-complex-2)
         (global.get $lex-rule-complex-unit-im-2)
         (global.get $lex-rule-complex-im-only-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-2/group-2))
 (global $lex-rule-complex-2/group-2 i32 (i32.const 63))

 (func $lex-match-infnan-im
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-infnan-im)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-infnan-im))
 (global $lex-rule-infnan-im i32 (i32.const 66))

 (func $lex-match-unit-im
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-unit-im)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-unit-im))
 (global $lex-rule-unit-im i32 (i32.const 66))

 (func $lex-match-simple-im
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-simple-im)
         (global.get $lex-rule-unit-im)
         (global.get $lex-rule-infnan-im)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-simple-im))
 (global $lex-rule-simple-im i32 (i32.const 66))

 (func $lex-match-complex-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-16)
         (global.get $lex-rule-complex-16/group-1)
         (global.get $lex-rule-complex-16/group-2)
         (global.get $lex-rule-simple-im)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-16))
 (global $lex-rule-complex-16 i32 (i32.const 63))

 (func $lex-match-complex-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-10)
         (global.get $lex-rule-complex-10/group-1)
         (global.get $lex-rule-complex-10/group-2)
         (global.get $lex-rule-simple-im)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-10))
 (global $lex-rule-complex-10 i32 (i32.const 63))

 (func $lex-match-complex-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-8)
         (global.get $lex-rule-complex-8/group-1)
         (global.get $lex-rule-complex-8/group-2)
         (global.get $lex-rule-simple-im)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-8))
 (global $lex-rule-complex-8 i32 (i32.const 63))

 (func $lex-match-complex-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-complex-2)
         (global.get $lex-rule-complex-2/group-1)
         (global.get $lex-rule-complex-2/group-2)
         (global.get $lex-rule-simple-im)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-complex-2))
 (global $lex-rule-complex-2 i32 (i32.const 63))

 (func $lex-match-num-16
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-num-16)
         (global.get $lex-rule-prefix-16)
         (global.get $lex-rule-complex-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-num-16))
 (global $lex-rule-num-16 i32 (i32.const 63))

 (func $lex-match-num-10
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-num-10)
         (global.get $lex-rule-prefix-10)
         (global.get $lex-rule-complex-10)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-num-10))
 (global $lex-rule-num-10 i32 (i32.const 63))

 (func $lex-match-num-8
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-num-8)
         (global.get $lex-rule-prefix-8)
         (global.get $lex-rule-complex-8)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-num-8))
 (global $lex-rule-num-8 i32 (i32.const 63))

 (func $lex-match-num-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-num-2)
         (global.get $lex-rule-prefix-2)
         (global.get $lex-rule-complex-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-num-2))
 (global $lex-rule-num-2 i32 (i32.const 63))

 (func $lex-match-number
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-number)
         (global.get $lex-rule-num-2)
         (global.get $lex-rule-num-8)
         (global.get $lex-rule-num-10)
         (global.get $lex-rule-num-16)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-number))
 (global $lex-rule-number i32 (i32.const 63))

 (func $lex-match-string-element/character
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-complement/ascii/set-of-2
         (global.get $lex-rule-string-element/character)
         (global.get $char-double-quote)
         (global.get $char-backslash)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-string-element/character))
 (global $lex-rule-string-element/character i32 (i32.const 63))

 (func $lex-match-mnemonic-escape-character
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-mnemonic-escape-character)
         (global.get $static-string-mnemonic-escapes)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-mnemonic-escape-character))
 (global $lex-rule-mnemonic-escape-character i32 (i32.const 63))

 (func $lex-match-backslash
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-backslash)
         (global.get $char-backslash)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-backslash))
 (global $lex-rule-backslash i32 (i32.const 37))

 (func $lex-match-double-quote
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-double-quote)
         (global.get $char-double-quote)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-double-quote))
 (global $lex-rule-double-quote i32 (i32.const 37))

 (func $lex-match-mnemonic-escape
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-mnemonic-escape)
         (global.get $lex-rule-backslash)
         (global.get $lex-rule-mnemonic-escape-character)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-mnemonic-escape))
 (global $lex-rule-mnemonic-escape i32 (i32.const 63))

 (func $lex-match-escaped-backslash
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-escaped-backslash)
         (global.get $lex-rule-backslash)
         (global.get $lex-rule-backslash)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-escaped-backslash))
 (global $lex-rule-escaped-backslash i32 (i32.const 63))

 (func $lex-match-escaped-double-quote
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-escaped-double-quote)
         (global.get $lex-rule-backslash)
         (global.get $lex-rule-double-quote)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-escaped-double-quote))
 (global $lex-rule-escaped-double-quote i32 (i32.const 63))

 (func $lex-match-string-element/character-escape
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-string-element/character-escape)
         (global.get $lex-rule-mnemonic-escape)
         (global.get $lex-rule-escaped-double-quote)
         (global.get $lex-rule-escaped-backslash)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-string-element/character-escape))
 (global $lex-rule-string-element/character-escape i32 (i32.const 63))

 (func $lex-match-intraline-whitespace-char
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-intraline-whitespace-char)
         (global.get $static-string-intraline-whitespace)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-intraline-whitespace-char))
 (global $lex-rule-intraline-whitespace-char i32 (i32.const 63))

 (func $lex-match-intraline-whitespace
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-intraline-whitespace)
         (global.get $lex-rule-intraline-whitespace-char)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-intraline-whitespace))
 (global $lex-rule-intraline-whitespace i32 (i32.const 63))

 (func $lex-match-line-ending-char
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-line-ending-char)
         (global.get $static-string-line-ending-charset)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-line-ending-char))
 (global $lex-rule-line-ending-char i32 (i32.const 63))

 (func $lex-match-dos-line-ending
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-dos-line-ending)
         (global.get $static-string-dos-line-ending)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-dos-line-ending))
 (global $lex-rule-dos-line-ending i32 (i32.const 63))

 (func $lex-match-line-ending
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-line-ending)
         (global.get $lex-rule-line-ending-char)
         (global.get $lex-rule-dos-line-ending)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-line-ending))
 (global $lex-rule-line-ending i32 (i32.const 63))

 (func $lex-match-escaped-line-ending
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-escaped-line-ending)
         (global.get $lex-rule-backslash)
         (global.get $lex-rule-intraline-whitespace)
         (global.get $lex-rule-line-ending)
         (global.get $lex-rule-intraline-whitespace)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-escaped-line-ending))
 (global $lex-rule-escaped-line-ending i32 (i32.const 63))

 (func $lex-match-hex-digit
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-hex-digit)
         (global.get $lex-rule-digit-16/0-9)
         (global.get $lex-rule-digit-16/a-f)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-hex-digit))
 (global $lex-rule-hex-digit i32 (i32.const 3))

 (func $lex-match-hex-scalar-value
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-hex-scalar-value)
         (global.get $lex-rule-hex-digit)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-hex-scalar-value))
 (global $lex-rule-hex-scalar-value i32 (i32.const 3))

 (func $lex-match-hex-inline-escape-prefix
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-hex-inline-escape-prefix)
         (global.get $static-string-inline-escape-prefix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-hex-inline-escape-prefix))
 (global $lex-rule-hex-inline-escape-prefix i32 (i32.const 3))

 (func $lex-match-hex-inline-escape
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-hex-inline-escape)
         (global.get $lex-rule-hex-inline-escape-prefix)
         (global.get $lex-rule-hex-scalar-value)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-hex-inline-escape))
 (global $lex-rule-hex-inline-escape i32 (i32.const 3))

 (func $lex-match-string-element
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-string-element)
         (global.get $lex-rule-string-element/character)
         (global.get $lex-rule-string-element/character-escape)
         (global.get $lex-rule-escaped-line-ending)
         (global.get $lex-rule-hex-inline-escape)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-string-element))
 (global $lex-rule-string-element i32 (i32.const 3))

 (func $lex-match-string-elements
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-string-elements)
         (global.get $lex-rule-string-element)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-string-elements))
 (global $lex-rule-string-elements i32 (i32.const 3))

 (func $lex-match-string
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-string)
         (global.get $lex-rule-double-quote)
         (global.get $lex-rule-string-elements)
         (global.get $lex-rule-double-quote)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-string))
 (global $lex-rule-string i32 (i32.const 3))

 (func $lex-match-boolean
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-4
         (global.get $lex-rule-boolean)
         (global.get $static-string-boolean-t)
         (global.get $static-string-boolean-f)
         (global.get $static-string-boolean-true)
         (global.get $static-string-boolean-false)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-boolean))
 (global $lex-rule-boolean i32 (i32.const 3))

 (func $lex-match-character-name/group-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-3
         (global.get $lex-rule-character-name/group-1)
         (global.get $static-string-alarm)
         (global.get $static-string-backspace)
         (global.get $static-string-delete)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character-name/group-1))
 (global $lex-rule-character-name/group-1 i32 (i32.const 3))

 (func $lex-match-character-name/group-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-3
         (global.get $lex-rule-character-name/group-2)
         (global.get $static-string-escape)
         (global.get $static-string-newline)
         (global.get $static-string-null)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character-name/group-2))
 (global $lex-rule-character-name/group-2 i32 (i32.const 3))

 (func $lex-match-character-name/group-3
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-3
         (global.get $lex-rule-character-name/group-3)
         (global.get $static-string-return)
         (global.get $static-string-space)
         (global.get $static-string-tab)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character-name/group-3))
 (global $lex-rule-character-name/group-3 i32 (i32.const 3))

 (func $lex-match-character-name
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-character-name)
         (global.get $lex-rule-character-name/group-1)
         (global.get $lex-rule-character-name/group-2)
         (global.get $lex-rule-character-name/group-3)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character-name))
 (global $lex-rule-character-name i32 (i32.const 3))

 (func $lex-match-character-prefix
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-character-prefix)
         (global.get $static-string-character-prefix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character-prefix))
 (global $lex-rule-character-prefix i32 (i32.const 3))

 (func $lex-match-named-character
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-named-character)
         (global.get $lex-rule-character-prefix)
         (global.get $lex-rule-character-name)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-named-character))
 (global $lex-rule-named-character i32 (i32.const 3))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-any-char))
 (global $lex-rule-any-char i32 (i32.const 11))

 (func $lex-match-escaped-character
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-escaped-character)
         (global.get $lex-rule-character-prefix)
         (global.get $lex-rule-any-char)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-escaped-character))
 (global $lex-rule-escaped-character i32 (i32.const 3))

 (func $lex-match-character-hex-prefix
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-character-hex-prefix)
         (global.get $static-string-character-hex-prefix)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character-hex-prefix))
 (global $lex-rule-character-hex-prefix i32 (i32.const 3))

 (func $lex-match-escaped-character-hex
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-escaped-character-hex)
         (global.get $lex-rule-character-hex-prefix)
         (global.get $lex-rule-hex-scalar-value)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-escaped-character-hex))
 (global $lex-rule-escaped-character-hex i32 (i32.const 3))

 (func $lex-match-character
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-character)
         (global.get $lex-rule-escaped-character)
         (global.get $lex-rule-named-character)
         (global.get $lex-rule-escaped-character-hex)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-character))
 (global $lex-rule-character i32 (i32.const 3))

 (func $lex-match-lowercase-letter
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (global.get $lex-rule-lowercase-letter)
         (global.get $char-a)
         (global.get $char-z)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-lowercase-letter))
 (global $lex-rule-lowercase-letter i32 (i32.const 6))

 (func $lex-match-uppercase-letter
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (global.get $lex-rule-uppercase-letter)
         (global.get $char-A)
         (global.get $char-Z)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-uppercase-letter))
 (global $lex-rule-uppercase-letter i32 (i32.const 6))

 (func $lex-match-letter
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-letter)
         (global.get $char-A)
         (global.get $char-Z)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-letter))
 (global $lex-rule-letter i32 (i32.const 6))

 (func $lex-match-special-initial
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-special-initial)
         (global.get $static-string-special-initials)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-special-initial))
 (global $lex-rule-special-initial i32 (i32.const 63))

 (func $lex-match-initial
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-initial)
         (global.get $lex-rule-letter)
         (global.get $lex-rule-special-initial)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-initial))
 (global $lex-rule-initial i32 (i32.const 63))

 (func $lex-match-special-subsequent-dot-or-at
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-special-subsequent-dot-or-at)
         (global.get $static-string-dot-and-at)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-special-subsequent-dot-or-at))
 (global $lex-rule-special-subsequent-dot-or-at i32 (i32.const 63))

 (func $lex-match-special-subsequent
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-special-subsequent)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-special-subsequent-dot-or-at)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-special-subsequent))
 (global $lex-rule-special-subsequent i32 (i32.const 63))

 (func $lex-match-subsequent
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-subsequent)
         (global.get $lex-rule-initial)
         (global.get $lex-rule-digit-10)
         (global.get $lex-rule-special-subsequent)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-subsequent))
 (global $lex-rule-subsequent i32 (i32.const 63))

 (func $lex-match-subsequents
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-subsequents)
         (global.get $lex-rule-subsequent)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-subsequents))
 (global $lex-rule-subsequents i32 (i32.const 63))

 (func $lex-match-ordinary-identifier
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-ordinary-identifier)
         (global.get $lex-rule-initial)
         (global.get $lex-rule-subsequents)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-ordinary-identifier))
 (global $lex-rule-ordinary-identifier i32 (i32.const 63))

 (func $lex-match-vertical-line
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-vertical-line)
         (global.get $char-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-vertical-line))
 (global $lex-rule-vertical-line i32 (i32.const 37))

 (func $lex-match-literal-symbol-element/character
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-complement/ascii/set-of-2
         (global.get $lex-rule-literal-symbol-element/character)
         (global.get $char-vertical-line)
         (global.get $char-backslash)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-literal-symbol-element/character))
 (global $lex-rule-literal-symbol-element/character i32 (i32.const 63))

 (func $lex-match-escaped-vertical-line
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-escaped-vertical-line)
         (global.get $lex-rule-backslash)
         (global.get $lex-rule-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-escaped-vertical-line))
 (global $lex-rule-escaped-vertical-line i32 (i32.const 63))

 (func $lex-match-literal-symbol-element
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-literal-symbol-element)
         (global.get $lex-rule-literal-symbol-element/character)
         (global.get $lex-rule-hex-inline-escape)
         (global.get $lex-rule-mnemonic-escape)
         (global.get $lex-rule-escaped-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-literal-symbol-element))
 (global $lex-rule-literal-symbol-element i32 (i32.const 3))

 (func $lex-match-literal-symbol-elements
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-literal-symbol-elements)
         (global.get $lex-rule-literal-symbol-element)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-literal-symbol-elements))
 (global $lex-rule-literal-symbol-elements i32 (i32.const 3))

 (func $lex-match-literal-symbol
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-literal-symbol)
         (global.get $lex-rule-vertical-line)
         (global.get $lex-rule-literal-symbol-elements)
         (global.get $lex-rule-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-literal-symbol))
 (global $lex-rule-literal-symbol i32 (i32.const 3))

 (func $lex-match-sign-subsequent
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-sign-subsequent)
         (global.get $lex-rule-initial)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-at-sign)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-sign-subsequent))
 (global $lex-rule-sign-subsequent i32 (i32.const 3))

 (func $lex-match-dot-subsequent
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-dot-subsequent)
         (global.get $lex-rule-sign-subsequent)
         (global.get $lex-rule-dot)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-dot-subsequent))
 (global $lex-rule-dot-subsequent i32 (i32.const 3))

 (func $lex-match-peculiar-identifier/form-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-peculiar-identifier/form-1)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-sign-subsequent)
         (global.get $lex-rule-subsequents)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-peculiar-identifier/form-1))
 (global $lex-rule-peculiar-identifier/form-1 i32 (i32.const 3))

 (func $lex-match-peculiar-identifier/form-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-peculiar-identifier/form-2)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-dot)
         (global.get $lex-rule-dot-subsequent)
         (global.get $lex-rule-subsequents)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-peculiar-identifier/form-2))
 (global $lex-rule-peculiar-identifier/form-2 i32 (i32.const 3))

 (func $lex-match-peculiar-identifier/form-3
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-peculiar-identifier/form-3)
         (global.get $lex-rule-dot)
         (global.get $lex-rule-dot-subsequent)
         (global.get $lex-rule-subsequents)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-peculiar-identifier/form-3))
 (global $lex-rule-peculiar-identifier/form-3 i32 (i32.const 3))

 (func $lex-match-peculiar-identifier
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-peculiar-identifier)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-peculiar-identifier/form-1)
         (global.get $lex-rule-peculiar-identifier/form-2)
         (global.get $lex-rule-peculiar-identifier/form-3)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-peculiar-identifier))
 (global $lex-rule-peculiar-identifier i32 (i32.const 3))

 (func $lex-match-identifier
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-identifier)
         (global.get $lex-rule-ordinary-identifier)
         (global.get $lex-rule-literal-symbol)
         (global.get $lex-rule-peculiar-identifier)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-identifier))
 (global $lex-rule-identifier i32 (i32.const 3))

 (func $lex-match-whitespace
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-whitespace)
         (global.get $lex-rule-intraline-whitespace)
         (global.get $lex-rule-line-ending)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-whitespace))
 (global $lex-rule-whitespace i32 (i32.const 3))

 (func $lex-match-semicolon
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-semicolon)
         (global.get $char-semicolon)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-semicolon))
 (global $lex-rule-semicolon i32 (i32.const 37))

 (func $lex-match-simple-comment-continuation
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-until-rule
         (global.get $lex-rule-simple-comment-continuation)
         (global.get $lex-rule-line-ending)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-simple-comment-continuation))
 (global $lex-rule-simple-comment-continuation i32 (i32.const 3))

 (func $lex-match-simple-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-simple-comment)
         (global.get $lex-rule-semicolon)
         (global.get $lex-rule-simple-comment-continuation)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-simple-comment))
 (global $lex-rule-simple-comment i32 (i32.const 3))

 (func $lex-match-nested-comment-delimiters
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-2
         (global.get $lex-rule-nested-comment-delimiters)
         (global.get $static-string-begin-nested-comment)
         (global.get $static-string-end-nested-comment)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-nested-comment-delimiters))
 (global $lex-rule-nested-comment-delimiters i32 (i32.const 3))

 (func $lex-match-comment-text
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-until-rule
         (global.get $lex-rule-comment-text)
         (global.get $lex-rule-nested-comment-delimiters)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-comment-text))
 (global $lex-rule-comment-text i32 (i32.const 3))

(func $lex-match-comment-continuation
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-comment-continuation)
         (global.get $lex-rule-nested-comment)
         (global.get $lex-rule-comment-text)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-comment-continuation))
 (global $lex-rule-comment-continuation i32 (i32.const 3))

(func $lex-match-comment-continuations
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-comment-continuations)
         (global.get $lex-rule-comment-continuation)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-comment-continuations))
 (global $lex-rule-comment-continuations i32 (i32.const 3))

(func $lex-match-begin-nested-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-begin-nested-comment)
         (global.get $static-string-begin-nested-comment)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-begin-nested-comment))
 (global $lex-rule-begin-nested-comment i32 (i32.const 3))

(func $lex-match-end-nested-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-end-nested-comment)
         (global.get $static-string-end-nested-comment)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-end-nested-comment))
 (global $lex-rule-end-nested-comment i32 (i32.const 3))

(func $lex-match-nested-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-nested-comment)
         (global.get $lex-rule-begin-nested-comment)
         (global.get $lex-rule-comment-text)
         (global.get $lex-rule-comment-continuations)
         (global.get $lex-rule-end-nested-comment)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-nested-comment))
 (global $lex-rule-nested-comment i32 (i32.const 3))

(func $lex-match-begin-datum-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-begin-datum-comment)
         (global.get $static-string-begin-datum-comment)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-begin-datum-comment))
 (global $lex-rule-begin-datum-comment i32 (i32.const 3))

(func $lex-match-datum-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-2
         (global.get $lex-rule-datum-comment)
         (global.get $lex-rule-begin-datum-comment)
         (global.get $lex-rule-intertoken-space)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-datum-comment))
 (global $lex-rule-datum-comment i32 (i32.const 3))

 (func $lex-match-directive
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-2
         (global.get $lex-rule-directive)
         (global.get $static-string-directive-fold-case)
         (global.get $static-string-directive-no-fold-case)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-directive))
 (global $lex-rule-directive i32 (i32.const 3))

 (func $lex-match-atmosphere
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-atmosphere)
         (global.get $lex-rule-whitespace)
         (global.get $lex-rule-comment)
         (global.get $lex-rule-directive)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-atmosphere))
 (global $lex-rule-atmosphere i32 (i32.const 3))

 (func $lex-match-intertoken-space
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-intertoken-space)
         (global.get $lex-rule-atmosphere)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-intertoken-space))
 (global $lex-rule-intertoken-space i32 (i32.const 3))

 (func $lex-match-comment
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-comment)
         (global.get $lex-rule-simple-comment)
         (global.get $lex-rule-nested-comment)
         (global.get $lex-rule-datum-comment)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-comment))
 (global $lex-rule-comment i32 (i32.const 3))

 (func $lex-match-delimiter-char
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-delimiter-char)
         (global.get $static-string-delimiter-charset)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-delimiter-char))
 (global $lex-rule-delimiter-char i32 (i32.const 3))

 (func $lex-match-delimiter
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-delimiter)
         (global.get $lex-rule-whitespace)
         (global.get $lex-rule-vertical-line)
         (global.get $lex-rule-delimiter-char)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-delimiter))
 (global $lex-rule-delimiter i32 (i32.const 3))

 (func $lex-match-token-char
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-token-char)
         (global.get $static-string-token-charset)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-token-char))
 (global $lex-rule-token-char i32 (i32.const 3))

 (func $lex-match-token-string
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/longest-of-3
         (global.get $lex-rule-token-string)
         (global.get $static-string-begin-syntax)
         (global.get $static-string-begin-bytevector)
         (global.get $static-string-unquote-splicing)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-token-string))
 (global $lex-rule-token-string i32 (i32.const 3))

 (func $lex-match-token/group-1
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-token/group-1)
         (global.get $lex-rule-number)
         (global.get $lex-rule-boolean)
         (global.get $lex-rule-character)
         (global.get $lex-rule-string)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-token/group-1))
 (global $lex-rule-token/group-1 i32 (i32.const 3))

 (func $lex-match-token/group-2
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-token/group-2)
         (global.get $lex-rule-identifier)
         (global.get $lex-rule-token-char)
         (global.get $lex-rule-token-string)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-token/group-2))
 (global $lex-rule-token/group-2 i32 (i32.const 3))

 (func $lex-match-token
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-token)
         (global.get $lex-rule-token/group-1)
         (global.get $lex-rule-token/group-2)
         (local.get $text)
         (local.get $end)))

 (elem (table $lexical-rules) funcref (ref.func $lex-match-token))
 (global $lex-rule-token i32 (i32.const 3))

 )
