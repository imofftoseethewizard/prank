(module
 (memory (export "memory") 1)

 (type $lexical-rule-func (func (param i32 i32 i32) (result i32 i32)))
 (table $lexical-rules 200 funcref)

 (func $ascii-lower (export "ascii-lower")
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

 (func $char-eq/ascii-ci (export "char-eq/ascii-ci")
   (param $x i32)
   (param $y i32)

   (result i32)

   (i32.or
    (i32.eq (local.get $x) (local.get $y))
    (i32.eq (call $ascii-lower (local.get $x) (call $ascii-lower (local.get $y))))))

 (func $lex-match-empty (export "lex-match-empty")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local.get $rule-id)
   (local.get $text))

 (func $lex-match-any-char (export "lex-match-any-char")
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

 (func $lex-match-char/ascii (export "lex-match-char/ascii")
   (param $rule-id i32)
   (param $char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32) (i32.eq (local.get $char) (local.get $c))
     (then
      (local.get $rule-id)
      (i32.add (i32.const 1) (local.get $text)))
     (else
      (local.get $rule-id)
      (i32.const -1))))

 (func $lex-match-char/ascii-ci (export "lex-match-char/ascii-ci")
   (param $rule-id i32)
   (param $char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32) (call $char-eq/ascii-ci (local.get $char) (local.get $c))
     (then
      (local.get $rule-id)
      (i32.add (i32.const 1) (local.get $text)))
     (else
      (local.get $rule-id)
      (i32.const -1))))

 (func $lex-match-char-complement/ascii/set-of-2 (export "lex-match-char-complement/ascii/set-of-2")
   (param $rule-id i32)
   (param $first-char i32)
   (param $second-char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32)
       (i32.and (i32.ne (local.get $first-char) (local.get $c))
                (i32.ne (local.get $second-char) (local.get $c)))
     (then
      (local.get $rule-id)
      (i32.add (i32.const 1) (local.get $text)))
     (else
      (local.get $rule-id)
      (i32.const -1))))

 (func $lex-match-char-range/ascii (export "lex-match-char-range/ascii")
   (param $rule-id i32)
   (param $min-char i32)
   (param $max-char i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $c i32)

   (if (i32.eq (local.get $text) (local.get $end))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.set $c (i32.load8_u (local.get $text)))

   (if (result i32 i32)
       (i32.and
        (i32.ge_u (local.get $c) (local.get $min-char))
        (i32.le_u (local.get $c) (local.get $max-char)))
     (then
      (local.get $rule-id)
      (i32.add (i32.const 1) (local.get $text)))
     (else
      (local.get $rule-id)
      (i32.const -1))))

 (func $match-charset (export "match-charset")
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

 (func $lex-match-charset (export "lex-match-charset")
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

 (func $match-static-string (export "match-static-string")
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

 (func $lex-match-static-string (export "lex-match-static-string")
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

 (func $match-static-string/ascii-ci (export "match-static-string/ascii-ci")
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

 (func $lex-match-static-string/ascii-ci (export "lex-match-static-string/ascii-ci")
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

 (func $lex-match-static-strings/longest-of-2 (export "lex-match-static-strings/longest-of-2")
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

 (func $lex-match-static-strings/ascii-ci/longest-of-2 (export "lex-match-static-strings/ascii-ci/longest-of-2")
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
              (call $match-static-string/ascii-ci
                    (i32.add (i32.const 1) (local.get $first-str))
                    (i32.load8_u (local.get $first-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string/ascii-ci
                    (i32.add (i32.const 1) (local.get $second-str))
                    (i32.load8_u (local.get $second-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.get $rule-id)
   (local.get $max-end))

 (func $lex-match-static-strings/longest-of-3 (export "lex-match-static-strings/longest-of-3")
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

 (func $lex-match-static-strings/ascii-ci/longest-of-3 (export "lex-match-static-strings/ascii-ci/longest-of-3")
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
              (call $match-static-string/ascii-ci
                    (i32.add (i32.const 1) (local.get $first-str))
                    (i32.load8_u (local.get $first-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string/ascii-ci
                    (i32.add (i32.const 1) (local.get $second-str))
                    (i32.load8_u (local.get $second-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.set $end-match
              (call $match-static-string/ascii-ci
                    (i32.add (i32.const 1) (local.get $third-str))
                    (i32.load8_u (local.get $third-str))
                    (local.get $text)
                    (local.get $end)))

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.get $rule-id)
   (local.get $max-end))

 (func $lex-match-static-strings/longest-of-4 (export "lex-match-static-strings/longest-of-4")
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

 (func $lex-match-rule? (export "lex-match-rule?")
   (param $rule-id i32)
   (param $target-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $target-rule-id) (local.get $text) (local.get $end)
                  (local.get $target-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (local.get $rule-id)
   (if (result i32) (i32.eq (local.get $end-match) (i32.const -1))
     (then
      (local.get $text))
     (else
      (local.get $end-match))))

 (func $lex-match-rule/zero-or-more (export "lex-match-rule/zero-or-more")
   (param $rule-id i32)
   (param $target-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)
   (local $next-end i32)

   (local.set $end-match (local.get $text))

   (loop $again
     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $target-rule-id) (local.get $end-match) (local.get $end)
                    (local.get $target-rule-id))

     (local.set $next-end)
     (drop) ;; matching rule id

     (if (i32.gt_s (local.get $next-end) (i32.const -1))
         (then
          (local.set $end-match (local.get $next-end))
          (br $again))))

   (local.get $rule-id)
   (local.get $end-match))

 (func $lex-match-rule/one-or-more (export "lex-match-rule/one-or-more")
   (param $rule-id i32)
   (param $target-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)
   (local $next-end i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $target-rule-id) (local.get $text) (local.get $end)
                  (local.get $target-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (loop $again
     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $target-rule-id) (local.get $end-match) (local.get $end)
                    (local.get $target-rule-id))

     (local.set $next-end)
     (drop) ;; matching rule id

     (if (i32.ne (local.get $next-end) (i32.const -1))
         (then
          (local.set $end-match (local.get $next-end))
          (br $again))))

   (local.get $rule-id)
   (local.get $end-match))

 (func $lex-match-rules/sequence (export "lex-match-rules/sequence")
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $last-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $current-rule-id i32)
   (local $end-match i32)

   (local.set $current-rule-id (local.get $first-rule-id))
   (local.set $end-match (local.get $text))

   (loop $again

     (call_indirect $lexical-rules (type $lexical-rule-func)
                    (local.get $current-rule-id) (local.get $end-match) (local.get $end)
                    (local.get $current-rule-id))

     (local.set $end-match)
     (drop) ;; matching rule id

     (if (i32.and
          (i32.gt_s (local.get $end-match) (i32.const -1))
          (i32.lt_u (local.get $current-rule-id) (local.get $last-rule-id)))
         (then
          (local.set $current-rule-id (i32.add (i32.const 1) (local.get $current-rule-id)))
          (br $again))))

   (local.get $rule-id)
   (local.get $end-match))

 (func $lex-match-rules/sequence-of-2 (export "lex-match-rules/sequence-of-2")
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $end-match) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.get $rule-id)
   (local.get $end-match))

 (func $lex-match-rules/sequence-of-3 (export "lex-match-rules/sequence-of-3")
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $third-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $end-match) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $end-match) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.get $rule-id)
   (local.get $end-match))

 (func $lex-match-rules/sequence-of-4 (export "lex-match-rules/sequence-of-4")
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $third-rule-id i32)
   (param $fourth-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $end-match) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $end-match) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $rule-id) (local.get $end-match) (local.get $end)
                  (local.get $fourth-rule-id))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.eq (local.get $end-match) (i32.const -1))
       (then
        (local.get $rule-id)
        (i32.const -1)
        (return)))

   (local.get $rule-id)
   (local.get $end-match))

 (func $lex-match-rules/longest (export "lex-match-rules/longest")
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

     (local.set $end-match)
     (local.set $matching-rule-id)

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

 (func $lex-match-rules/longest-of-2 (export "lex-match-rules/longest-of-2")
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

   (local.set $longest-matching-rule-id (local.get $rule-id))
   (local.set $max-end (i32.const -1))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/longest-of-3 (export "lex-match-rules/longest-of-3")
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

   (local.set $longest-matching-rule-id (local.get $rule-id))
   (local.set $max-end (i32.const -1))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $third-rule-id) (local.get $text) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/longest-of-4 (export "lex-match-rules/longest-of-4")
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

   (local.set $longest-matching-rule-id (local.get $rule-id))
   (local.set $max-end (i32.const -1))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $first-rule-id) (local.get $text) (local.get $end)
                  (local.get $first-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $second-rule-id) (local.get $text) (local.get $end)
                  (local.get $second-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $third-rule-id) (local.get $text) (local.get $end)
                  (local.get $third-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (call_indirect $lexical-rules (type $lexical-rule-func)
                  (local.get $fourth-rule-id) (local.get $text) (local.get $end)
                  (local.get $fourth-rule-id))

   (local.set $end-match)
   (local.set $matching-rule-id)

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $longest-matching-rule-id (local.get $matching-rule-id))
        (local.set $max-end (local.get $end-match))))

   (local.get $longest-matching-rule-id)
   (local.get $max-end))

 (func $lex-match-rules/longest-unordered-sequence-of-2 (export "lex-match-rules/longest-unordered-sequence-of-2")
   (param $rule-id i32)
   (param $first-rule-id i32)
   (param $second-rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $end-match i32)
   (local $max-end i32)

   (local.set $max-end (i32.const -1))

   (call $lex-match-rules/sequence-of-2
         (local.get $rule-id)
         (local.get $first-rule-id)
         (local.get $second-rule-id)
         (local.get $text)
         (local.get $end))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (call $lex-match-rules/sequence-of-2
         (local.get $rule-id)
         (local.get $second-rule-id)
         (local.get $first-rule-id)
         (local.get $text)
         (local.get $end))

   (local.set $end-match)
   (drop) ;; matching rule id

   (if (i32.gt_s (local.get $end-match) (local.get $max-end))
       (then
        (local.set $max-end (local.get $end-match))))

   (local.get $rule-id)
   (local.get $max-end))

 (func $lex-match-until-rule (export "lex-match-until-rule")
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

     (local.set $end-match)
     (drop) ;; matching rule id

     (if (i32.and
          (i32.lt_u (local.get $current) (local.get $end))
          (i32.eq (i32.const -1) (local.get $end-match)))
         (then
          (local.set $current (i32.add (i32.const 1) (local.get $current)))
          (br $again))))

   (local.get $rule-id)
   (local.get $current))

 (func $lex-token-relabel (export "lex-token-relabel")
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

   (local.set $end-match)
   (local.set $matching-rule-id)

   (local.get $new-rule-id)
   (local.get $end-match))

 (global $char-line-feed       i32 (i32.const 10))
 (global $char-carriage-return i32 (i32.const 13))
 (global $char-space           i32 (i32.const 32))
 (global $char-double-quote    i32 (i32.const 34))
 (global $char-hash-mark       i32 (i32.const 35))
 (global $char-open-paren      i32 (i32.const 40))
 (global $char-close-paren     i32 (i32.const 41))
 (global $char-plus            i32 (i32.const 43))
 (global $char-minus           i32 (i32.const 45))
 (global $char-dot             i32 (i32.const 46))
 (global $char-slash           i32 (i32.const 47))
 (global $char-0               i32 (i32.const 48))
 (global $char-1               i32 (i32.const 49))
 (global $char-7               i32 (i32.const 55))
 (global $char-9               i32 (i32.const 57))
 (global $char-semicolon       i32 (i32.const 59))
 (global $char-at-sign         i32 (i32.const 64))
 (global $char-A               i32 (i32.const 65))
 (global $char-F               i32 (i32.const 70))
 (global $char-Z               i32 (i32.const 90))
 (global $char-backslash       i32 (i32.const 92))
 (global $char-a               i32 (i32.const 97))
 (global $char-b               i32 (i32.const 98))
 (global $char-d               i32 (i32.const 100))
 (global $char-e               i32 (i32.const 101))
 (global $char-f               i32 (i32.const 102))
 (global $char-i               i32 (i32.const 105))
 (global $char-o               i32 (i32.const 111))
 (global $char-x               i32 (i32.const 120))
 (global $char-z               i32 (i32.const 123))
 (global $char-vertical-line   i32 (i32.const 124))

 ;; <token> -> <identifier> | <boolean> | <number>
 ;;            | <character> | <string>
 ;;            | ( | ) | # ( | #u8( | ’ | ` | , | ,@ | .

 (func $lex-match-token (export "lex-match-token")
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

 (elem funcref (ref.func $lex-match-token))
 (global $lex-rule-token (export "lex-rule-token") i32 (i32.const 0))

 (func $lex-match-token/group-1 (export "lex-match-token/group-1")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-token/group-1)
         ;; $lex-rule-number appears before $lex-rule-identifier
         ;; so that +i, -1, and <infnan> are categorized as numbers
         ;; in the lexer, rather than needing special handling further
         ;; downstream in the reader
         (global.get $lex-rule-number)
         (global.get $lex-rule-identifier)
         (global.get $lex-rule-boolean)
         (global.get $lex-rule-character)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-token/group-1))
 (global $lex-rule-token/group-1 (export "lex-rule-token/group-1") i32 (i32.const 1))

 (func $lex-match-token/group-2 (export "lex-match-token/group-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-token/group-2)
         (global.get $lex-rule-string)
         (global.get $lex-rule-token-char)
         (global.get $lex-rule-token-string)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-token/group-2))
 (global $lex-rule-token/group-2 (export "lex-rule-token/group-2") i32 (i32.const 2))

 (func $lex-match-token-char (export "lex-match-token-char")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-token-char)
         (global.get $static-string-token-charset)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-token-char))
 (global $lex-rule-token-char (export "lex-rule-token-char") i32 (i32.const 3))

 (data (offset (i32.const 0x0000)) "\06()'`,.")
 (global $static-string-token-charset (export "static-string-token-charset") i32 (i32.const 0x0000))

 (func $lex-match-token-string (export "lex-match-token-string")
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

 (elem funcref (ref.func $lex-match-token-string))
 (global $lex-rule-token-string (export "lex-rule-token-string") i32 (i32.const 4))

 (data (offset (i32.const 0x0010)) "\02#(")
 (data (offset (i32.const 0x0020)) "\04#u8(")
 (data (offset (i32.const 0x0030)) "\02,@")

 (global $static-string-begin-syntax (export "static-string-begin-syntax")         i32 (i32.const 0x0010))
 (global $static-string-begin-bytevector (export "static-string-begin-bytevector") i32 (i32.const 0x0020))
 (global $static-string-unquote-splicing (export "static-string-unquote-splicing") i32 (i32.const 0x0030))

 ;; <delimiter>-> <whitespace> | <vertical line>| ( | ) | " | ;

 (func $lex-match-delimiter (export "lex-match-delimiter")
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

 (elem funcref (ref.func $lex-match-delimiter))
 (global $lex-rule-delimiter (export "lex-rule-delimiter") i32 (i32.const 5))

 (func $lex-match-delimiter-char (export "lex-match-delimiter-char")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-delimiter-char)
         (global.get $static-string-delimiter-charset)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-delimiter-char))
 (global $lex-rule-delimiter-char (export "lex-rule-delimiter-char") i32 (i32.const 6))

 (data (offset (i32.const 0x0040)) "\05|()\22\3b") ;; \22 is double-quote, \3b is semicolon
 (global $static-string-delimiter-charset (export "static-string-delimiter-charset") i32 (i32.const 0x0040))

 ;; <intraline whitespace> -> <space or tab>

 (func $lex-match-intraline-whitespace (export "lex-match-intraline-whitespace")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-intraline-whitespace)
         (global.get $static-string-intraline-whitespace)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-intraline-whitespace))
 (global $lex-rule-intraline-whitespace (export "lex-rule-intraline-whitespace") i32 (i32.const 7))

 (data (offset (i32.const 0x0050)) "\02 \09") ;; tab and space
 (global $static-string-intraline-whitespace (export "static-string-intraline-whitespace") i32 (i32.const 0x0050))

 ;; <whitespace>-> <intraline whitespace> | <line ending>

 (func $lex-match-whitespace (export "lex-match-whitespace")
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

 (elem funcref (ref.func $lex-match-whitespace))
 (global $lex-rule-whitespace (export "lex-rule-whitespace") i32 (i32.const 8))

 ;; <vertical line> -> |

 (func $lex-match-vertical-line (export "lex-match-vertical-line")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-vertical-line)
         (global.get $char-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-vertical-line))
 (global $lex-rule-vertical-line (export "lex-rule-vertical-line") i32 (i32.const 9))

 ;; <line ending> -> <newline> | <return> <newline> | <return>

 (func $lex-match-line-ending (export "lex-match-line-ending")
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

 (elem funcref (ref.func $lex-match-line-ending))
 (global $lex-rule-line-ending (export "lex-rule-line-ending") i32 (i32.const 10))

 (func $lex-match-line-ending-char (export "lex-match-line-ending-char")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-line-ending-char)
         (global.get $static-string-line-ending-charset)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-line-ending-char))
 (global $lex-rule-line-ending-char (export "lex-rule-line-ending-char") i32 (i32.const 11))

 (data (offset (i32.const 0x0060)) "\02\0d\0a") ;; cr lf
 (global $static-string-line-ending-charset (export "static-string-line-ending-charset") i32 (i32.const 0x0060))

 (func $lex-match-dos-line-ending (export "lex-match-dos-line-ending")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-dos-line-ending)
         (global.get $static-string-dos-line-ending)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-dos-line-ending))
 (global $lex-rule-dos-line-ending (export "lex-rule-dos-line-ending") i32 (i32.const 12))

 ;; cr lf -- dos/windows line ending
 (data (offset (i32.const 0x0070)) "\02\0d\0a")
 (global $static-string-dos-line-ending (export "static-string-dos-line-ending") i32 (i32.const 0x0070))

 ;; <comment> -> ; <all subsequent characters up to a line ending>
 ;;                | <nested comment>
 ;;                | #; <intertoken space> <datum>

 (func $lex-match-comment (export "lex-match-comment")
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

 (elem funcref (ref.func $lex-match-comment))
 (global $lex-rule-comment (export "lex-rule-comment") i32 (i32.const 13))

 (func $lex-match-simple-comment (export "lex-match-simple-comment")
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

 (elem funcref (ref.func $lex-match-simple-comment))
 (global $lex-rule-simple-comment (export "lex-rule-simple-comment") i32 (i32.const 14))

 (func $lex-match-semicolon (export "lex-match-semicolon")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-semicolon)
         (global.get $char-semicolon)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-semicolon))
 (global $lex-rule-semicolon (export "lex-rule-semicolon") i32 (i32.const 15))

 (func $lex-match-simple-comment-continuation (export "lex-match-simple-comment-continuation")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-until-rule
         (global.get $lex-rule-simple-comment-continuation)
         (global.get $lex-rule-line-ending)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-simple-comment-continuation))
 (global $lex-rule-simple-comment-continuation (export "lex-rule-simple-comment-continuation") i32 (i32.const 16))

 (func $lex-match-datum-comment (export "lex-match-datum-comment")
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

 (elem funcref (ref.func $lex-match-datum-comment))
 (global $lex-rule-datum-comment (export "lex-rule-datum-comment") i32 (i32.const 17))

 (func $lex-match-begin-datum-comment (export "lex-match-begin-datum-comment")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-begin-datum-comment)
         (global.get $static-string-begin-datum-comment)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-begin-datum-comment))
 (global $lex-rule-begin-datum-comment (export "lex-rule-begin-datum-comment") i32 (i32.const 18))

 (data (offset (i32.const 0x0080)) "\02#;")
 (global $static-string-begin-datum-comment (export "static-string-begin-datum-comment") i32 (i32.const 0x0080))

 ;;<nested comment> -> #| <comment text> <comment cont>* |#

 (func $lex-match-nested-comment (export "lex-match-nested-comment")
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

 (elem funcref (ref.func $lex-match-nested-comment))
 (global $lex-rule-nested-comment (export "lex-rule-nested-comment") i32 (i32.const 19))

 (func $lex-match-begin-nested-comment (export "lex-match-begin-nested-comment")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-begin-nested-comment)
         (global.get $static-string-begin-nested-comment)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-begin-nested-comment))
 (global $lex-rule-begin-nested-comment (export "lex-rule-begin-nested-comment") i32 (i32.const 20))

 (data (offset (i32.const 0x0090)) "\02#|")
 (global $static-string-begin-nested-comment (export "static-string-begin-nested-comment") i32 (i32.const 0x0090))

 (func $lex-match-comment-continuations (export "lex-match-comment-continuations")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-comment-continuations)
         (global.get $lex-rule-comment-continuation)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-comment-continuations))
 (global $lex-rule-comment-continuations (export "lex-rule-comment-continuations") i32 (i32.const 21))

 (func $lex-match-end-nested-comment (export "lex-match-end-nested-comment")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-end-nested-comment)
         (global.get $static-string-end-nested-comment)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-end-nested-comment))
 (global $lex-rule-end-nested-comment (export "lex-rule-end-nested-comment") i32 (i32.const 22))

 (data (offset (i32.const 0x00a0)) "\02|#")
 (global $static-string-end-nested-comment (export "static-string-end-nested-comment") i32 (i32.const 0x00a0))

 ;;<comment text> -> <character sequence not containing #| or |#>

 (func $lex-match-comment-text (export "lex-match-comment-text")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-until-rule
         (global.get $lex-rule-comment-text)
         (global.get $lex-rule-nested-comment-delimiters)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-comment-text))
 (global $lex-rule-comment-text (export "lex-rule-comment-text") i32 (i32.const 23))

 (func $lex-match-nested-comment-delimiters (export "lex-match-nested-comment-delimiters")
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

 (elem funcref (ref.func $lex-match-nested-comment-delimiters))
 (global $lex-rule-nested-comment-delimiters (export "lex-rule-nested-comment-delimiters") i32 (i32.const 24))

 ;; <comment cont> -> <nested comment> <comment text>

 (func $lex-match-comment-continuation (export "lex-match-comment-continuation")
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

 (elem funcref (ref.func $lex-match-comment-continuation))
 (global $lex-rule-comment-continuation (export "lex-rule-comment-continuation") i32 (i32.const 25))

 ;; <directive> -> #!fold-case | #!no-fold-case

 (func $lex-match-directive (export "lex-match-directive")
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

 (elem funcref (ref.func $lex-match-directive))
 (global $lex-rule-directive (export "lex-rule-directive") i32 (i32.const 26))

 (data (offset (i32.const 0x00b0)) "\0b#!fold-case")
 (data (offset (i32.const 0x00c0)) "\0e#!no-fold-case")
 (global $static-string-directive-fold-case (export "static-string-directive-fold-case")       i32 (i32.const 0x00b0))
 (global $static-string-directive-no-fold-case (export "static-string-directive-no-fold-case") i32 (i32.const 0x00c0))

 ;; <atmosphere> -> <whitespace> | <comment> | <directive>

 (func $lex-match-atmosphere (export "lex-match-atmosphere")
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

 (elem funcref (ref.func $lex-match-atmosphere))
 (global $lex-rule-atmosphere (export "lex-rule-atmosphere") i32 (i32.const 27))

 ;; <intertoken space> -> <atmosphere>

 (func $lex-match-intertoken-space (export "lex-match-intertoken-space")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-intertoken-space)
         (global.get $lex-rule-atmosphere)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-intertoken-space))
 (global $lex-rule-intertoken-space (export "lex-rule-intertoken-space") i32 (i32.const 28))

 ;; <identifier> -> <initial> <subsequent>*
 ;;                    | <vertical line> <symbol element>* <vertical line>
 ;;                    | <peculiar identifier>

 (func $lex-match-identifier (export "lex-match-identifier")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-identifier)
         (global.get $lex-rule-ordinary-identifier)
         (global.get $lex-rule-vertical-line-quoted-symbol)
         (global.get $lex-rule-peculiar-identifier)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-identifier))
 (global $lex-rule-identifier (export "lex-rule-identifier") i32 (i32.const 29))

 (func $lex-match-ordinary-identifier (export "lex-match-ordinary-identifier")
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

 (elem funcref (ref.func $lex-match-ordinary-identifier))
 (global $lex-rule-ordinary-identifier (export "lex-rule-ordinary-identifier") i32 (i32.const 30))

 (func $lex-match-subsequents (export "lex-match-subsequents")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-subsequents)
         (global.get $lex-rule-subsequent)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-subsequents))
 (global $lex-rule-subsequents (export "lex-rule-subsequents") i32 (i32.const 31))

 (func $lex-match-vertical-line-quoted-symbol (export "lex-match-vertical-line-quoted-symbol")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-vertical-line-quoted-symbol)
         (global.get $lex-rule-vertical-line)
         (global.get $lex-rule-symbol-elements)
         (global.get $lex-rule-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-vertical-line-quoted-symbol))
 (global $lex-rule-vertical-line-quoted-symbol (export "lex-rule-vertical-line-quoted-symbol") i32 (i32.const 32))

 (func $lex-match-symbol-elements (export "lex-match-symbol-elements")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-symbol-elements)
         (global.get $lex-rule-symbol-element)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-symbol-elements))
 (global $lex-rule-symbol-elements (export "lex-rule-symbol-elements") i32 (i32.const 33))

 ;;<initial> -> <letter> | <special initial>

 (func $lex-match-initial (export "lex-match-initial")
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

 (elem funcref (ref.func $lex-match-initial))
 (global $lex-rule-initial (export "lex-rule-initial") i32 (i32.const 34))

 ;;<letter> -> a | b | c | ... | z | A | B | C | ... | Z

 (func $lex-match-letter (export "lex-match-letter")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-letter)
         (global.get $lex-rule-lowercase-letter)
         (global.get $lex-rule-uppercase-letter)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-letter))
 (global $lex-rule-letter (export "lex-rule-letter") i32 (i32.const 35))

 (func $lex-match-lowercase-letter (export "lex-match-lowercase-letter")
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

 (elem funcref (ref.func $lex-match-lowercase-letter))
 (global $lex-rule-lowercase-letter (export "lex-rule-lowercase-letter") i32 (i32.const 36))

 (func $lex-match-uppercase-letter (export "lex-match-uppercase-letter")
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

 (elem funcref (ref.func $lex-match-uppercase-letter))
 (global $lex-rule-uppercase-letter (export "lex-rule-uppercase-letter") i32 (i32.const 37))


 ;; <special initial> -> ! | $ | % | & | * | / | : | < | = | > | ? | ^ | _ | ~

 (func $lex-match-special-initial (export "lex-match-special-initial")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-special-initial)
         (global.get $static-string-special-initials)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-special-initial))
 (global $lex-rule-special-initial (export "lex-rule-special-initial") i32 (i32.const 38))

 (data (offset (i32.const 0x00d0)) "\0e!$%&*/:<=>?^_~")
 (global $static-string-special-initials (export "static-string-special-initials") i32 (i32.const 0x00d0))

 ;;<subsequent> -> <initial> | <digit> | <special subsequent>

  (func $lex-match-subsequent (export "lex-match-subsequent")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-subsequent)
         (global.get $lex-rule-initial)
         (global.get $lex-rule-digit)
         (global.get $lex-rule-special-subsequent)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-subsequent))
 (global $lex-rule-subsequent (export "lex-rule-subsequent") i32 (i32.const 39))

;; <digit> -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

 (func $lex-match-digit (export "lex-match-digit")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (global.get $lex-rule-digit)
         (global.get $char-0)
         (global.get $char-9)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-digit))
 (global $lex-rule-digit (export "lex-rule-digit") i32 (i32.const 40))

 ;; <hex digit> -> <digit> | a | b | c | d | e | f

 (func $lex-match-hex-digit (export "lex-match-hex-digit")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-hex-digit)
         (global.get $lex-rule-digit)
         (global.get $lex-rule-hex-digit/alphabetic)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-hex-digit))
 (global $lex-rule-hex-digit (export "lex-rule-hex-digit") i32 (i32.const 41))

 (func $lex-match-hex-digit/alphabetic (export "lex-match-hex-digit/alphabetic")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (global.get $lex-rule-hex-digit/alphabetic)
         (global.get $char-a)
         (global.get $char-f)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-hex-digit/alphabetic))
 (global $lex-rule-hex-digit/alphabetic (export "lex-rule-hex-digit/alphabetic") i32 (i32.const 42))

 ;; <explicit sign> -> + | -

  (func $lex-match-explicit-sign (export "lex-match-explicit-sign")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-explicit-sign)
         (global.get $static-string-explicit-sign-charset)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-explicit-sign))
 (global $lex-rule-explicit-sign (export "lex-rule-explicit-sign") i32 (i32.const 43))

 (data (offset (i32.const 0x00e0)) "\02+-")
 (global $static-string-explicit-sign-charset (export "static-string-explicit-sign-charset") i32 (i32.const 0x00e0))

 ;; <special subsequent> -> <explicit sign> | . | @

 (func $lex-match-special-subsequent (export "lex-match-special-subsequent")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-special-subsequent)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-special-subsequent/dot-or-at)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-special-subsequent))
 (global $lex-rule-special-subsequent (export "lex-rule-special-subsequent") i32 (i32.const 44))

 (func $lex-match-special-subsequent/dot-or-at (export "lex-match-special-subsequent/dot-or-at")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-special-subsequent/dot-or-at)
         (global.get $static-string-dot-and-at)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-special-subsequent/dot-or-at))
 (global $lex-rule-special-subsequent/dot-or-at (export "lex-rule-special-subsequent/dot-or-at") i32 (i32.const 45))

 (data (offset (i32.const 0x00f0)) "\02.@")
 (global $static-string-dot-and-at (export "static-string-dot-and-at") i32 (i32.const 0x00f0))

 ;; <inline hex escape> -> \x<hex scalar value>;

 (func $lex-match-inline-hex-escape (export "lex-match-inline-hex-escape")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-inline-hex-escape)
         (global.get $lex-rule-inline-hex-escape-prefix)
         (global.get $lex-rule-hex-scalar-value)
         (global.get $lex-rule-semicolon)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-inline-hex-escape))
 (global $lex-rule-inline-hex-escape (export "lex-rule-inline-hex-escape") i32 (i32.const 46))

 (func $lex-match-inline-hex-escape-prefix (export "lex-match-inline-hex-escape-prefix")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-inline-hex-escape-prefix)
         (global.get $static-string-inline-escape-prefix)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-inline-hex-escape-prefix))
 (global $lex-rule-inline-hex-escape-prefix (export "lex-rule-inline-hex-escape-prefix") i32 (i32.const 47))

 (data (offset (i32.const 0x0100)) "\02\\x")
 (global $static-string-inline-escape-prefix (export "static-string-inline-escape-prefix") i32 (i32.const 0x0100))

 ;; <hex scalar value> -> <hex digit>+

 (func $lex-match-hex-scalar-value (export "lex-match-hex-scalar-value")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-hex-scalar-value)
         (global.get $lex-rule-hex-digit)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-hex-scalar-value))
 (global $lex-rule-hex-scalar-value (export "lex-rule-hex-scalar-value") i32 (i32.const 48))

 ;;<mnemonic escape> -> \a | \b | \t | \n | \r

 (func $lex-match-mnemonic-escape (export "lex-match-mnemonic-escape")
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

 (elem funcref (ref.func $lex-match-mnemonic-escape))
 (global $lex-rule-mnemonic-escape (export "lex-rule-mnemonic-escape") i32 (i32.const 49))

 (func $lex-match-backslash (export "lex-match-backslash")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-backslash)
         (global.get $char-backslash)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-backslash))
 (global $lex-rule-backslash (export "lex-rule-backslash") i32 (i32.const 50))

 (func $lex-match-mnemonic-escape-character (export "lex-match-mnemonic-escape-character")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-charset
         (global.get $lex-rule-mnemonic-escape-character)
         (global.get $static-string-mnemonic-escapes)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-mnemonic-escape-character))
 (global $lex-rule-mnemonic-escape-character (export "lex-rule-mnemonic-escape-character") i32 (i32.const 51))

 (data (offset (i32.const 0x0110)) "\05abnrt")
 (global $static-string-mnemonic-escapes (export "static-string-mnemonic-escapes") i32 (i32.const 0x0110))

 ;; <peculiar identifier> -> <explicit sign>
 ;;                             | <explicit sign> <sign subsequent> <subsequent>*
 ;;                             | <explicit sign> . <dot subsequent> <subsequent>*
 ;;                             | . <dot subsequent> <subsequent>*

 (func $lex-match-peculiar-identifier (export "lex-match-peculiar-identifier")
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

 (elem funcref (ref.func $lex-match-peculiar-identifier))
 (global $lex-rule-peculiar-identifier (export "lex-rule-peculiar-identifier") i32 (i32.const 52))

 (func $lex-match-peculiar-identifier/form-1 (export "lex-match-peculiar-identifier/form-1")
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

 (elem funcref (ref.func $lex-match-peculiar-identifier/form-1))
 (global $lex-rule-peculiar-identifier/form-1 (export "lex-rule-peculiar-identifier/form-1") i32 (i32.const 53))

 (func $lex-match-peculiar-identifier/form-2 (export "lex-match-peculiar-identifier/form-2")
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

 (elem funcref (ref.func $lex-match-peculiar-identifier/form-2))
 (global $lex-rule-peculiar-identifier/form-2 (export "lex-rule-peculiar-identifier/form-2") i32 (i32.const 54))

 (func $lex-match-dot (export "lex-match-dot")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-dot)
         (global.get $char-dot)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-dot))
 (global $lex-rule-dot (export "lex-rule-dot") i32 (i32.const 55))

 (func $lex-match-peculiar-identifier/form-3 (export "lex-match-peculiar-identifier/form-3")
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

 (elem funcref (ref.func $lex-match-peculiar-identifier/form-3))
 (global $lex-rule-peculiar-identifier/form-3 (export "lex-rule-peculiar-identifier/form-3") i32 (i32.const 56))

 ;; <dot subsequent> -> <sign subsequent> | .

 (func $lex-match-dot-subsequent (export "lex-match-dot-subsequent")
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

 (elem funcref (ref.func $lex-match-dot-subsequent))
 (global $lex-rule-dot-subsequent (export "lex-rule-dot-subsequent") i32 (i32.const 57))

 ;; <sign subsequent> -> <initial> | <explicit sign> | @

 (func $lex-match-sign-subsequent (export "lex-match-sign-subsequent")
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

 (elem funcref (ref.func $lex-match-sign-subsequent))
 (global $lex-rule-sign-subsequent (export "lex-rule-sign-subsequent") i32 (i32.const 58))

 (func $lex-match-at-sign (export "lex-match-at-sign")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-at-sign)
         (global.get $char-at-sign)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-at-sign))
 (global $lex-rule-at-sign (export "lex-rule-at-sign") i32 (i32.const 59))

 ;; <symbol element> -> <any character other than <vertical line> or \>
 ;;                        | <inline hex escape>
 ;;                        | <mnemonic escape>
 ;;                        | \|

 (func $lex-match-symbol-element (export "lex-match-symbol-element")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-symbol-element)
         (global.get $lex-rule-symbol-element/character)
         (global.get $lex-rule-inline-hex-escape)
         (global.get $lex-rule-mnemonic-escape)
         (global.get $lex-rule-escaped-vertical-line)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-symbol-element))
 (global $lex-rule-symbol-element (export "lex-rule-symbol-element") i32 (i32.const 60))

 (func $lex-match-symbol-element/character (export "lex-match-symbol-element/character")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-complement/ascii/set-of-2
         (global.get $lex-rule-symbol-element/character)
         (global.get $char-vertical-line)
         (global.get $char-backslash)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-symbol-element/character))
 (global $lex-rule-symbol-element/character (export "lex-rule-symbol-element/character") i32 (i32.const 61))

 (func $lex-match-escaped-vertical-line (export "lex-match-escaped-vertical-line")
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

 (elem funcref (ref.func $lex-match-escaped-vertical-line))
 (global $lex-rule-escaped-vertical-line (export "lex-rule-escaped-vertical-line") i32 (i32.const 62))

 ;; <boolean> -> #t | #f | #true | #false

  (func $lex-match-boolean (export "lex-match-boolean")
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

 (elem funcref (ref.func $lex-match-boolean))
 (global $lex-rule-boolean (export "lex-rule-boolean") i32 (i32.const 63))

 (data (offset (i32.const 0x0120)) "\02#t")
 (data (offset (i32.const 0x0130)) "\02#f")
 (data (offset (i32.const 0x0140)) "\05#true")
 (data (offset (i32.const 0x0150)) "\06#false")
 (global $static-string-boolean-t     (export "static-string-boolean-t")     i32 (i32.const 0x0120))
 (global $static-string-boolean-f     (export "static-string-boolean-f")     i32 (i32.const 0x0130))
 (global $static-string-boolean-true  (export "static-string-boolean-true")  i32 (i32.const 0x0140))
 (global $static-string-boolean-false (export "static-string-boolean-false") i32 (i32.const 0x0150))


 ;; <character> -> #\ <any character>
 ;;                  | #\ <character name>
 ;;                  | #\x<hex scalar value>

 (func $lex-match-character (export "lex-match-character")
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

 (elem funcref (ref.func $lex-match-character))
 (global $lex-rule-character (export "lex-rule-character") i32 (i32.const 64))

 (func $lex-match-escaped-character (export "lex-match-escaped-character")
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

 (elem funcref (ref.func $lex-match-escaped-character))
 (global $lex-rule-escaped-character (export "lex-rule-escaped-character") i32 (i32.const 65))

 (elem funcref (ref.func $lex-match-any-char))
 (global $lex-rule-any-char (export "lex-rule-any-char") i32 (i32.const 66))

 (func $lex-match-character-prefix (export "lex-match-character-prefix")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-character-prefix)
         (global.get $static-string-character-prefix)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-character-prefix))
 (global $lex-rule-character-prefix (export "lex-rule-character-prefix") i32 (i32.const 67))

 (data (offset (i32.const 0x0160)) "\02#\\")
 (global $static-string-character-prefix (export "static-string-character-prefix") i32 (i32.const 0x0160))

 (func $lex-match-named-character (export "lex-match-named-character")
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

 (elem funcref (ref.func $lex-match-named-character))
 (global $lex-rule-named-character (export "lex-rule-named-character") i32 (i32.const 68))

 (func $lex-match-escaped-character-hex (export "lex-match-escaped-character-hex")
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

 (elem funcref (ref.func $lex-match-escaped-character-hex))
 (global $lex-rule-escaped-character-hex (export "lex-rule-escaped-character-hex") i32 (i32.const 69))

 (func $lex-match-character-hex-prefix (export "lex-match-character-hex-prefix")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string
         (global.get $lex-rule-character-hex-prefix)
         (global.get $static-string-character-hex-prefix)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-character-hex-prefix))
 (global $lex-rule-character-hex-prefix (export "lex-rule-character-hex-prefix") i32 (i32.const 70))

 (data (offset (i32.const 0x0170)) "\03#\\x")
 (global $static-string-character-hex-prefix (export "static-string-character-hex-prefix") i32 (i32.const 0x0170))

 ;; <character name> -> alarm | backspace | delete | escape
 ;;                       | newline | null | return | space | tab

 (func $lex-match-character-name (export "lex-match-character-name")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (local $match-end i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-character-name)
         (global.get $lex-rule-character-name/group-1)
         (global.get $lex-rule-character-name/group-2)
         (global.get $lex-rule-character-name/group-3)
         (local.get $text)
         (local.get $end))

   ;; the "longest-of" rule combiners will return the sub rule id, but
   ;; here that isn't useful, so discard it and replace with the combined rule.

   (local.set $match-end)
   (drop) ;; rule-id

   (global.get $lex-rule-character-name)
   (local.get $match-end))

 (elem funcref (ref.func $lex-match-character-name))
 (global $lex-rule-character-name (export "lex-rule-character-name") i32 (i32.const 71))

 (func $lex-match-character-name/group-1 (export "lex-match-character-name/group-1")
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

 (elem funcref (ref.func $lex-match-character-name/group-1))
 (global $lex-rule-character-name/group-1 (export "lex-rule-character-name/group-1") i32 (i32.const 72))

 (func $lex-match-character-name/group-2 (export "lex-match-character-name/group-2")
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

 (elem funcref (ref.func $lex-match-character-name/group-2))
 (global $lex-rule-character-name/group-2 (export "lex-rule-character-name/group-2") i32 (i32.const 73))

 (func $lex-match-character-name/group-3 (export "lex-match-character-name/group-3")
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

 (elem funcref (ref.func $lex-match-character-name/group-3))
 (global $lex-rule-character-name/group-3 (export "lex-rule-character-name/group-3") i32 (i32.const 74))

 (data (offset (i32.const 0x0180)) "\05alarm")
 (data (offset (i32.const 0x0190)) "\09backspace")
 (data (offset (i32.const 0x01a0)) "\06delete")
 (data (offset (i32.const 0x01b0)) "\06escape")
 (data (offset (i32.const 0x01c0)) "\07newline")
 (data (offset (i32.const 0x01d0)) "\04null")
 (data (offset (i32.const 0x01e0)) "\06return")
 (data (offset (i32.const 0x01f0)) "\05space")
 (data (offset (i32.const 0x0200)) "\03tab")
 (global $static-string-alarm     (export "static-string-alarm")     i32 (i32.const 0x0180))
 (global $static-string-backspace (export "static-string-backspace") i32 (i32.const 0x0190))
 (global $static-string-delete    (export "static-string-delete")    i32 (i32.const 0x01a0))
 (global $static-string-escape    (export "static-string-escape")    i32 (i32.const 0x01b0))
 (global $static-string-newline   (export "static-string-newline")   i32 (i32.const 0x01c0))
 (global $static-string-null      (export "static-string-null")      i32 (i32.const 0x01d0))
 (global $static-string-return    (export "static-string-return")    i32 (i32.const 0x01e0))
 (global $static-string-space     (export "static-string-space")     i32 (i32.const 0x01f0))
 (global $static-string-tab       (export "static-string-tab")       i32 (i32.const 0x0200))

 ;; <string> -> " <string element>* "

 (func $lex-match-string (export "lex-match-string")
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

 (elem funcref (ref.func $lex-match-string))
 (global $lex-rule-string (export "lex-rule-string") i32 (i32.const 75))

 (func $lex-match-double-quote (export "lex-match-double-quote")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-double-quote)
         (global.get $char-double-quote)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-double-quote))
 (global $lex-rule-double-quote (export "lex-rule-double-quote") i32 (i32.const 76))

 (func $lex-match-string-elements (export "lex-match-string-elements")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-string-elements)
         (global.get $lex-rule-string-element)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-string-elements))
 (global $lex-rule-string-elements (export "lex-rule-string-elements") i32 (i32.const 77))

 ;; <string element> -> <any character other than " or \>
 ;;                        | <mnemonic escape> | \ " | \\
 ;;                        | \<intraline whitespace>*<line ending><intraline whitespace>*
 ;;                        | <inline hex escape>

 (func $lex-match-string-element (export "lex-match-string-element")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-4
         (global.get $lex-rule-string-element)
         (global.get $lex-rule-string-element/character)
         (global.get $lex-rule-string-element/character-escape)
         (global.get $lex-rule-escaped-line-ending)
         (global.get $lex-rule-inline-hex-escape)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-string-element))
 (global $lex-rule-string-element (export "lex-rule-string-element") i32 (i32.const 78))

 (func $lex-match-string-element/character (export "lex-match-string-element/character")
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

 (elem funcref (ref.func $lex-match-string-element/character))
 (global $lex-rule-string-element/character (export "lex-rule-string-element/character") i32 (i32.const 79))

 (func $lex-match-string-element/character-escape (export "lex-match-string-element/character-escape")
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

 (elem funcref (ref.func $lex-match-string-element/character-escape))
 (global $lex-rule-string-element/character-escape (export "lex-rule-string-element/character-escape") i32 (i32.const 80))

 (func $lex-match-escaped-double-quote (export "lex-match-escaped-double-quote")
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

 (elem funcref (ref.func $lex-match-escaped-double-quote))
 (global $lex-rule-escaped-double-quote (export "lex-rule-escaped-double-quote") i32 (i32.const 81))

 (func $lex-match-escaped-backslash (export "lex-match-escaped-backslash")
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

 (elem funcref (ref.func $lex-match-escaped-backslash))
 (global $lex-rule-escaped-backslash (export "lex-rule-escaped-backslash") i32 (i32.const 82))

 (func $lex-match-escaped-line-ending (export "lex-match-escaped-line-ending")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-escaped-line-ending)
         (global.get $lex-rule-backslash)
         (global.get $lex-rule-some-intraline-whitespace)
         (global.get $lex-rule-line-ending)
         (global.get $lex-rule-some-intraline-whitespace)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-escaped-line-ending))
 (global $lex-rule-escaped-line-ending (export "lex-rule-escaped-line-ending") i32 (i32.const 83))

 (func $lex-match-some-intraline-whitespace (export "lex-match-some-intraline-whitespace")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-some-intraline-whitespace)
         (global.get $lex-rule-intraline-whitespace)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-some-intraline-whitespace))
 (global $lex-rule-some-intraline-whitespace (export "lex-rule-some-intraline-whitespace") i32 (i32.const 84))

;;<number> -> <num 2> | <num 8> | <num 10> | <num 16>

 (func $lex-match-number (export "lex-match-number")
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

 (elem funcref (ref.func $lex-match-number))
 (global $lex-rule-number (export "lex-rule-number") i32 (i32.const 85))

 ;; <num 2> -> <prefix 2> <complex 2>

 (func $lex-match-num-2 (export "lex-match-num-2")
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

 (elem funcref (ref.func $lex-match-num-2))
 (global $lex-rule-num-2 (export "lex-rule-num-2") i32 (i32.const 86))

 ;; <num 8> -> <prefix 8> <complex 8>

 (func $lex-match-num-8 (export "lex-match-num-8")
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

 (elem funcref (ref.func $lex-match-num-8))
 (global $lex-rule-num-8 (export "lex-rule-num-8") i32 (i32.const 87))

 ;; <num 10> -> <prefix 10> <complex 10>

 (func $lex-match-num-10 (export "lex-match-num-10")
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

 (elem funcref (ref.func $lex-match-num-10))
 (global $lex-rule-num-10 (export "lex-rule-num-10") i32 (i32.const 88))

 ;; <num 16> -> <prefix 16> <complex 16>

 (func $lex-match-num-16 (export "lex-match-num-16")
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

 (elem funcref (ref.func $lex-match-num-16))
 (global $lex-rule-num-16 (export "lex-rule-num-16") i32 (i32.const 89))

 ;; <complex R> -> <real R> | <real R> @ <real R>
 ;;                   | <real R> + <ureal R> i | <real R> - <ureal R> i
 ;;                   | <real R> + i | <real R> - i | <real R> <infnan> i
 ;;                   | + <ureal R> i | - <ureal R> i
 ;;                   | <infnan> i | + i | - i

  (func $lex-match-complex-16 (export "lex-match-complex-16")
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

 (elem funcref (ref.func $lex-match-complex-16))
 (global $lex-rule-complex-16 (export "lex-rule-complex-16") i32 (i32.const 90))

 (func $lex-match-complex-10 (export "lex-match-complex-10")
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

 (elem funcref (ref.func $lex-match-complex-10))
 (global $lex-rule-complex-10 (export "lex-rule-complex-10") i32 (i32.const 91))

 (func $lex-match-complex-8 (export "lex-match-complex-8")
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

 (elem funcref (ref.func $lex-match-complex-8))
 (global $lex-rule-complex-8 (export "lex-rule-complex-8") i32 (i32.const 92))

 (func $lex-match-complex-2 (export "lex-match-complex-2")
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

 (elem funcref (ref.func $lex-match-complex-2))
 (global $lex-rule-complex-2 (export "lex-rule-complex-2") i32 (i32.const 93))

 (func $lex-match-simple-im (export "lex-match-simple-im")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-simple-im)
         (global.get $lex-rule-unit-im)
         (global.get $lex-rule-infnan-im)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-simple-im))
 (global $lex-rule-simple-im (export "lex-rule-simple-im") i32 (i32.const 94))

 (func $lex-match-unit-im (export "lex-match-unit-im")
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

 (elem funcref (ref.func $lex-match-unit-im))
 (global $lex-rule-unit-im (export "lex-rule-unit-im") i32 (i32.const 95))

 (func $lex-match-complex-i (export "lex-match-complex-i")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii-ci
         (global.get $lex-rule-complex-i)
         (global.get $char-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-i))
 (global $lex-rule-complex-i (export "lex-rule-complex-i") i32 (i32.const 96))

 (func $lex-match-infnan-im (export "lex-match-infnan-im")
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

 (elem funcref (ref.func $lex-match-infnan-im))
 (global $lex-rule-infnan-im (export "lex-rule-infnan-im") i32 (i32.const 97))

 (func $lex-match-complex-16/group-1 (export "lex-match-complex-16/group-1")
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

 (elem funcref (ref.func $lex-match-complex-16/group-1))
 (global $lex-rule-complex-16/group-1 (export "lex-rule-complex-16/group-1") i32 (i32.const 98))

 (func $lex-match-complex-10/group-1 (export "lex-match-complex-10/group-1")
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

 (elem funcref (ref.func $lex-match-complex-10/group-1))
 (global $lex-rule-complex-10/group-1 (export "lex-rule-complex-10/group-1") i32 (i32.const 99))

 (func $lex-match-complex-8/group-1 (export "lex-match-complex-8/group-1")
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

 (elem funcref (ref.func $lex-match-complex-8/group-1))
 (global $lex-rule-complex-8/group-1 (export "lex-rule-complex-8/group-1") i32 (i32.const 100))

 (func $lex-match-complex-2/group-1 (export "lex-match-complex-2/group-1")
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

 (elem funcref (ref.func $lex-match-complex-2/group-1))
 (global $lex-rule-complex-2/group-1 (export "lex-rule-complex-2/group-1") i32 (i32.const 101))

 (func $lex-match-complex-polar-16 (export "lex-match-complex-polar-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-16)
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-real-16)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-polar-16))
 (global $lex-rule-complex-polar-16 (export "lex-rule-complex-polar-16") i32 (i32.const 102))

 (func $lex-match-complex-polar-10 (export "lex-match-complex-polar-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-10)
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-real-10)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-polar-10))
 (global $lex-rule-complex-polar-10 (export "lex-rule-complex-polar-10") i32 (i32.const 103))

 (func $lex-match-complex-polar-8 (export "lex-match-complex-polar-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-8)
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-real-8)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-polar-8))
 (global $lex-rule-complex-polar-8 (export "lex-rule-complex-polar-8") i32 (i32.const 104))

 (func $lex-match-complex-polar-2 (export "lex-match-complex-polar-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-polar-2)
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-at-sign)
         (global.get $lex-rule-real-2)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-polar-2))
 (global $lex-rule-complex-polar-2 (export "lex-rule-complex-polar-2") i32 (i32.const 105))

 (func $lex-match-complex-infnan-im-16 (export "lex-match-complex-infnan-im-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-16)
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-infnan-im-16))
 (global $lex-rule-complex-infnan-im-16 (export "lex-rule-complex-infnan-im-16") i32 (i32.const 106))

 (func $lex-match-complex-infnan-im-10 (export "lex-match-complex-infnan-im-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-10)
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-infnan-im-10))
 (global $lex-rule-complex-infnan-im-10 (export "lex-rule-complex-infnan-im-10") i32 (i32.const 107))

 (func $lex-match-complex-infnan-im-8 (export "lex-match-complex-infnan-im-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-8)
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-infnan-im-8))
 (global $lex-rule-complex-infnan-im-8 (export "lex-rule-complex-infnan-im-8") i32 (i32.const 108))

 (func $lex-match-complex-infnan-im-2 (export "lex-match-complex-infnan-im-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-infnan-im-2)
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-infnan)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-infnan-im-2))
 (global $lex-rule-complex-infnan-im-2 (export "lex-rule-complex-infnan-im-2") i32 (i32.const 109))

 (func $lex-match-complex-16/group-2 (export "lex-match-complex-16/group-2")
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

 (elem funcref (ref.func $lex-match-complex-16/group-2))
 (global $lex-rule-complex-16/group-2 (export "lex-rule-complex-16/group-2") i32 (i32.const 110))

 (func $lex-match-complex-10/group-2 (export "lex-match-complex-10/group-2")
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

 (elem funcref (ref.func $lex-match-complex-10/group-2))
 (global $lex-rule-complex-10/group-2 (export "lex-rule-complex-10/group-2") i32 (i32.const 111))

 (func $lex-match-complex-8/group-2 (export "lex-match-complex-8/group-2")
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

 (elem funcref (ref.func $lex-match-complex-8/group-2))
 (global $lex-rule-complex-8/group-2 (export "lex-rule-complex-8/group-2") i32 (i32.const 112))

 (func $lex-match-complex-2/group-2 (export "lex-match-complex-2/group-2")
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

 (elem funcref (ref.func $lex-match-complex-2/group-2))
 (global $lex-rule-complex-2/group-2 (export "lex-rule-complex-2/group-2") i32 (i32.const 113))

 (func $lex-match-full-complex-16 (export "lex-match-full-complex-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-16)
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-16)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-full-complex-16))
 (global $lex-rule-full-complex-16 (export "lex-rule-full-complex-16") i32 (i32.const 114))

 (func $lex-match-full-complex-10 (export "lex-match-full-complex-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-10)
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-10)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-full-complex-10))
 (global $lex-rule-full-complex-10 (export "lex-rule-full-complex-10") i32 (i32.const 115))

 (func $lex-match-full-complex-8 (export "lex-match-full-complex-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-8)
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-8)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-full-complex-8))
 (global $lex-rule-full-complex-8 (export "lex-rule-full-complex-8") i32 (i32.const 116))

 (func $lex-match-full-complex-2 (export "lex-match-full-complex-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-4
         (global.get $lex-rule-full-complex-2)
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-ureal-2)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-full-complex-2))
 (global $lex-rule-full-complex-2 (export "lex-rule-full-complex-2") i32 (i32.const 117))

 (func $lex-match-complex-unit-im-16 (export "lex-match-complex-unit-im-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-16)
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-unit-im-16))
 (global $lex-rule-complex-unit-im-16 (export "lex-rule-complex-unit-im-16") i32 (i32.const 118))

 (func $lex-match-complex-unit-im-10 (export "lex-match-complex-unit-im-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-10)
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-unit-im-10))
 (global $lex-rule-complex-unit-im-10 (export "lex-rule-complex-unit-im-10") i32 (i32.const 119))

 (func $lex-match-complex-unit-im-8 (export "lex-match-complex-unit-im-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-8)
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-unit-im-8))
 (global $lex-rule-complex-unit-im-8 (export "lex-rule-complex-unit-im-8") i32 (i32.const 120))

 (func $lex-match-complex-unit-im-2 (export "lex-match-complex-unit-im-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/sequence-of-3
         (global.get $lex-rule-complex-unit-im-2)
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-explicit-sign)
         (global.get $lex-rule-complex-i)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-complex-unit-im-2))
 (global $lex-rule-complex-unit-im-2 (export "lex-rule-complex-unit-im-2") i32 (i32.const 121))

 (func $lex-match-complex-im-only-16 (export "lex-match-complex-im-only-16")
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

 (elem funcref (ref.func $lex-match-complex-im-only-16))
 (global $lex-rule-complex-im-only-16 (export "lex-rule-complex-im-only-16") i32 (i32.const 122))

 (func $lex-match-complex-im-only-10 (export "lex-match-complex-im-only-10")
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

 (elem funcref (ref.func $lex-match-complex-im-only-10))
 (global $lex-rule-complex-im-only-10 (export "lex-rule-complex-im-only-10") i32 (i32.const 123))

 (func $lex-match-complex-im-only-8 (export "lex-match-complex-im-only-8")
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

 (elem funcref (ref.func $lex-match-complex-im-only-8))
 (global $lex-rule-complex-im-only-8 (export "lex-rule-complex-im-only-8") i32 (i32.const 124))

 (func $lex-match-complex-im-only-2 (export "lex-match-complex-im-only-2")
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

 (elem funcref (ref.func $lex-match-complex-im-only-2))
 (global $lex-rule-complex-im-only-2 (export "lex-rule-complex-im-only-2") i32 (i32.const 125))

 ;;<real R> -> <sign> <ureal R> | <infnan>

 (func $lex-match-real-16 (export "lex-match-real-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-16)
         (global.get $lex-rule-signed-real-16)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-real-16))
 (global $lex-rule-real-16 (export "lex-rule-real-16") i32 (i32.const 126))

 (func $lex-match-real-10 (export "lex-match-real-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-10)
         (global.get $lex-rule-signed-real-10)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-real-10))
 (global $lex-rule-real-10 (export "lex-rule-real-10") i32 (i32.const 127))

 (func $lex-match-real-8 (export "lex-match-real-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-8)
         (global.get $lex-rule-signed-real-8)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-real-8))
 (global $lex-rule-real-8 (export "lex-rule-real-8") i32 (i32.const 128))

 (func $lex-match-real-2 (export "lex-match-real-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-2
         (global.get $lex-rule-real-2)
         (global.get $lex-rule-signed-real-2)
         (global.get $lex-rule-infnan)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-real-2))
 (global $lex-rule-real-2 (export "lex-rule-real-2") i32 (i32.const 129))

 (func $lex-match-signed-real-16 (export "lex-match-signed-real-16")
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

 (elem funcref (ref.func $lex-match-signed-real-16))
 (global $lex-rule-signed-real-16 (export "lex-rule-signed-real-16") i32 (i32.const 130))

 (func $lex-match-signed-real-10 (export "lex-match-signed-real-10")
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

 (elem funcref (ref.func $lex-match-signed-real-10))
 (global $lex-rule-signed-real-10 (export "lex-rule-signed-real-10") i32 (i32.const 131))

 (func $lex-match-signed-real-8 (export "lex-match-signed-real-8")
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

 (elem funcref (ref.func $lex-match-signed-real-8))
 (global $lex-rule-signed-real-8 (export "lex-rule-signed-real-8") i32 (i32.const 132))

 (func $lex-match-signed-real-2 (export "lex-match-signed-real-2")
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

 (elem funcref (ref.func $lex-match-signed-real-2))
 (global $lex-rule-signed-real-2 (export "lex-rule-signed-real-2") i32 (i32.const 133))


;; <ureal R> -> <uinteger R> | <uinteger R> / <uinteger R> | <decimal R>
;;  Note: the decimal term is only present for R = 10

 (func $lex-match-ureal-16 (export "lex-match-ureal-16")
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

 (elem funcref (ref.func $lex-match-ureal-16))
 (global $lex-rule-ureal-16 (export "lex-rule-ureal-16") i32 (i32.const 134))

 (func $lex-match-ureal-10 (export "lex-match-ureal-10")
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

 (elem funcref (ref.func $lex-match-ureal-10))
 (global $lex-rule-ureal-10 (export "lex-rule-ureal-10") i32 (i32.const 135))

 (func $lex-match-ureal-8 (export "lex-match-ureal-8")
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

 (elem funcref (ref.func $lex-match-ureal-8))
 (global $lex-rule-ureal-8 (export "lex-rule-ureal-8") i32 (i32.const 136))

 (func $lex-match-ureal-2 (export "lex-match-ureal-2")
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

 (elem funcref (ref.func $lex-match-ureal-2))
 (global $lex-rule-ureal-2 (export "lex-rule-ureal-2") i32 (i32.const 137))

 (func $lex-match-urational-16 (export "lex-match-urational-16")
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

 (elem funcref (ref.func $lex-match-urational-16))
 (global $lex-rule-urational-16 (export "lex-rule-urational-16") i32 (i32.const 138))

 (func $lex-match-urational-10 (export "lex-match-urational-10")
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

 (elem funcref (ref.func $lex-match-urational-10))
 (global $lex-rule-urational-10 (export "lex-rule-urational-10") i32 (i32.const 139))

 (func $lex-match-urational-8 (export "lex-match-urational-8")
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

 (elem funcref (ref.func $lex-match-urational-8))
 (global $lex-rule-urational-8 (export "lex-rule-urational-8") i32 (i32.const 140))

 (func $lex-match-urational-2 (export "lex-match-urational-2")
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

 (elem funcref (ref.func $lex-match-urational-2))
 (global $lex-rule-urational-2 (export "lex-rule-urational-2") i32 (i32.const 141))

 (func $lex-match-slash (export "lex-match-slash")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii
         (global.get $lex-rule-slash)
         (global.get $char-slash)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-slash))
 (global $lex-rule-slash (export "lex-rule-slash") i32 (i32.const 142))

;; <decimal 10> -> <uinteger 10> <suffix>
;;                    | . <digit 10>+ <suffix>
;;                    | <digit 10>+ . <digit 10>* <suffix>

 (func $lex-match-decimal-10 (export "lex-match-decimal-10")
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

 (elem funcref (ref.func $lex-match-decimal-10))
 (global $lex-rule-decimal-10 (export "lex-rule-decimal-10") i32 (i32.const 143))

 (func $lex-match-decimal-10-forms (export "lex-match-decimal-10-forms")
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

 (elem funcref (ref.func $lex-match-decimal-10-forms))
 (global $lex-rule-decimal-10-forms (export "lex-rule-decimal-10-forms") i32 (i32.const 144))

 (func $lex-match-dot-digits-10 (export "lex-match-dot-digits-10")
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

 (elem funcref (ref.func $lex-match-dot-digits-10))
 (global $lex-rule-dot-digits-10 (export "lex-rule-dot-digits-10") i32 (i32.const 145))

 (func $lex-match-digits-10 (export "lex-match-digits-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-digits-10)
         (global.get $lex-rule-digit-10)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-digits-10))
 (global $lex-rule-digits-10 (export "lex-rule-digits-10") i32 (i32.const 146))

 (func $lex-match-digits-dot-digits-10 (export "lex-match-digits-dot-digits-10")
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

 (elem funcref (ref.func $lex-match-digits-dot-digits-10))
 (global $lex-rule-digits-dot-digits-10 (export "lex-rule-digits-dot-digits-10") i32 (i32.const 147))

 (func $lex-match-digits-10? (export "lex-match-digits-10?")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/zero-or-more
         (global.get $lex-rule-digits-10?)
         (global.get $lex-rule-digit-10)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-digits-10?))
 (global $lex-rule-digits-10? (export "lex-rule-digits-10?") i32 (i32.const 148))

 ;; <uinteger R> -> <digit R>

 (func $lex-match-uinteger-16 (export "lex-match-uinteger-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-16)
         (global.get $lex-rule-digit-16)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-uinteger-16))
 (global $lex-rule-uinteger-16 (export "lex-rule-uinteger-16") i32 (i32.const 149))

 (func $lex-match-uinteger-10 (export "lex-match-uinteger-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-10)
         (global.get $lex-rule-digit-10)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-uinteger-10))
 (global $lex-rule-uinteger-10 (export "lex-rule-uinteger-10") i32 (i32.const 150))

 (func $lex-match-uinteger-8 (export "lex-match-uinteger-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-8)
         (global.get $lex-rule-digit-8)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-uinteger-8))
 (global $lex-rule-uinteger-8 (export "lex-rule-uinteger-8") i32 (i32.const 151))

 (func $lex-match-uinteger-2 (export "lex-match-uinteger-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule/one-or-more
         (global.get $lex-rule-uinteger-2)
         (global.get $lex-rule-digit-2)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-uinteger-2))
 (global $lex-rule-uinteger-2 (export "lex-rule-uinteger-2") i32 (i32.const 152))

 ;; <prefix R> -> <radix R> <exactness> | <exactness> <radix R>

 (func $lex-match-prefix-16 (export "lex-match-prefix-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-unordered-sequence-of-2
         (global.get $lex-rule-prefix-16)
         (global.get $lex-rule-radix-16)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-prefix-16))
 (global $lex-rule-prefix-16 (export "lex-rule-prefix-16") i32 (i32.const 153))

 (func $lex-match-prefix-10 (export "lex-match-prefix-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-unordered-sequence-of-2
         (global.get $lex-rule-prefix-10)
         (global.get $lex-rule-radix-10)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-prefix-10))
 (global $lex-rule-prefix-10 (export "lex-rule-prefix-10") i32 (i32.const 154))

 (func $lex-match-prefix-8 (export "lex-match-prefix-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-unordered-sequence-of-2
         (global.get $lex-rule-prefix-8)
         (global.get $lex-rule-radix-8)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-prefix-8))
 (global $lex-rule-prefix-8 (export "lex-rule-prefix-8") i32 (i32.const 155))

 (func $lex-match-prefix-2 (export "lex-match-prefix-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-unordered-sequence-of-2
         (global.get $lex-rule-prefix-2)
         (global.get $lex-rule-radix-2)
         (global.get $lex-rule-exactness)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-prefix-2))
 (global $lex-rule-prefix-2 (export "lex-rule-prefix-2") i32 (i32.const 156))

 ;; <infnan> -> +inf.0 | -inf.0 | +nan.0 | -nan.0

 (func $lex-match-infnan (export "lex-match-infnan")
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

 (elem funcref (ref.func $lex-match-infnan))
 (global $lex-rule-infnan (export "lex-rule-infnan") i32 (i32.const 157))

 (func $lex-match-inf-or-nan (export "lex-match-inf-or-nan")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/ascii-ci/longest-of-2
         (global.get $lex-rule-inf-or-nan)
         (global.get $static-string-inf)
         (global.get $static-string-nan)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-inf-or-nan))
 (global $lex-rule-inf-or-nan (export "lex-rule-inf-or-nan") i32 (i32.const 158))

 (data (offset (i32.const 0x0210)) "\05inf.0")
 (data (offset (i32.const 0x0220)) "\05nan.0")
 (global $static-string-inf (export "static-string-inf") i32 (i32.const 0x0210))
 (global $static-string-nan (export "static-string-nan") i32 (i32.const 0x0220))

 ;; <suffix> -> <empty> | <exponent marker> <sign> <digit 10>+

 (func $lex-match-suffix (export "lex-match-suffix")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule?
         (global.get $lex-rule-suffix)
         (global.get $lex-rule-suffix-sequence)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-suffix))
 (global $lex-rule-suffix (export "lex-rule-suffix") i32 (i32.const 159))

 (func $lex-match-suffix-sequence (export "lex-match-suffix-sequence")
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

 (elem funcref (ref.func $lex-match-suffix-sequence))
 (global $lex-rule-suffix-sequence (export "lex-rule-suffix-sequence") i32 (i32.const 160))

 ;; <exponent marker> -> e

 (func $lex-match-exponent-marker (export "lex-match-exponent-marker")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char/ascii-ci
         (global.get $lex-rule-exponent-marker)
         (global.get $char-e)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-exponent-marker))
 (global $lex-rule-exponent-marker (export "lex-rule-exponent-marker") i32 (i32.const 161))

 ;;<sign> -> <empty> | + | -

 (func $lex-match-sign (export "lex-match-sign")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rule?
         (global.get $lex-rule-sign)
         (global.get $lex-rule-explicit-sign)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-sign))
 (global $lex-rule-sign (export "lex-rule-sign") i32 (i32.const 162))

 ;; <exactness> -> <empty> | #i | #e

 (func $lex-match-exactness (export "lex-match-exactness")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/ascii-ci/longest-of-3
         (global.get $lex-rule-exactness)
         (global.get $static-string-empty)
         (global.get $static-string-exact-prefix)
         (global.get $static-string-inexact-prefix)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-exactness))
 (global $lex-rule-exactness (export "lex-rule-exactness") i32 (i32.const 163))

 (data (offset (i32.const 0x0230)) "\00")
 (data (offset (i32.const 0x0240)) "\02#e")
 (data (offset (i32.const 0x0250)) "\02#i")
 (global $static-string-empty          (export "static-string-empty")          i32 (i32.const 0x0230))
 (global $static-string-exact-prefix   (export "static-string-exact-prefix")   i32 (i32.const 0x0240))
 (global $static-string-inexact-prefix (export "static-string-inexact-prefix") i32 (i32.const 0x0250))


 ;; <radix 2> -> #b

 (func $lex-match-radix-2 (export "lex-match-radix-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (global.get $lex-rule-radix-2)
         (global.get $static-string-radix-2)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-radix-2))
 (global $lex-rule-radix-2 (export "lex-rule-radix-2") i32 (i32.const 164))

 (data (offset (i32.const 0x0260)) "\02#b")
 (global $static-string-radix-2 (export "static-string-radix-2") i32 (i32.const 0x0260))

 ;; <radix 8> -> #o

 (func $lex-match-radix-8 (export "lex-match-radix-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (global.get $lex-rule-radix-8)
         (global.get $static-string-radix-8)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-radix-8))
 (global $lex-rule-radix-8 (export "lex-rule-radix-8") i32 (i32.const 165))

 (data (offset (i32.const 0x0270)) "\02#o")
 (global $static-string-radix-8 (export "static-string-radix-8") i32 (i32.const 0x0270))

 ;;<radix 10> -> <empty> | #d

 (func $lex-match-radix-10 (export "lex-match-radix-10")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-strings/ascii-ci/longest-of-2
         (global.get $lex-rule-radix-10)
         (global.get $static-string-empty)
         (global.get $static-string-radix-10)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-radix-10))
 (global $lex-rule-radix-10 (export "lex-rule-radix-10") i32 (i32.const 166))

 (data (offset (i32.const 0x0280)) "\02#d")
 (global $static-string-radix-10 (export "static-string-radix-10") i32 (i32.const 0x0280))

 ;; <radix 16> -> #x

 (func $lex-match-radix-16 (export "lex-match-radix-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-static-string/ascii-ci
         (global.get $lex-rule-radix-16)
         (global.get $static-string-radix-16)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-radix-16))
 (global $lex-rule-radix-16 (export "lex-rule-radix-16") i32 (i32.const 167))

 (data (offset (i32.const 0x0290)) "\02#x")
 (global $static-string-radix-16 (export "static-string-radix-16") i32 (i32.const 0x0290))

 ;; <digit 2> -> 0 | 1

 (func $lex-match-digit-2 (export "lex-match-digit-2")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (global.get $lex-rule-digit-2)
         (global.get $char-0)
         (global.get $char-1)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-digit-2))
 (global $lex-rule-digit-2 (export "lex-rule-digit-2") i32 (i32.const 168))

 ;; <digit 8> -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7

 (func $lex-match-digit-8 (export "lex-match-digit-8")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-char-range/ascii
         (global.get $lex-rule-digit-8)
         (global.get $char-0)
         (global.get $char-7)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-digit-8))
 (global $lex-rule-digit-8 (export "lex-rule-digit-8") i32 (i32.const 169))

 ;; <digit 10> -> <digit>

 (elem funcref (ref.func $lex-match-digit))
 (global $lex-rule-digit-10 (export "lex-rule-digit-10") i32 (i32.const 170))

 ;; <digit 16> -> <digit 10> | a | b | c | d | e | f

 (func $lex-match-digit-16 (export "lex-match-digit-16")
   (param $rule-id i32)
   (param $text i32)
   (param $end i32)

   (result i32 i32)

   (call $lex-match-rules/longest-of-3
         (global.get $lex-rule-digit-16)
         (global.get $lex-rule-digit-10)
         (global.get $lex-rule-digit-16/A-F)
         (global.get $lex-rule-digit-16/a-f)
         (local.get $text)
         (local.get $end)))

 (elem funcref (ref.func $lex-match-digit-16))
 (global $lex-rule-digit-16 (export "lex-rule-digit-16") i32 (i32.const 171))

 (func $lex-match-digit-16/A-F (export "lex-match-digit-16/A-F")
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

 (elem funcref (ref.func $lex-match-digit-16/A-F))
 (global $lex-rule-digit-16/A-F (export "lex-rule-digit-16/A-F") i32 (i32.const 172))

 (func $lex-match-digit-16/a-f (export "lex-match-digit-16/a-f")
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

 (elem funcref (ref.func $lex-match-digit-16/a-f))
 (global $lex-rule-digit-16/a-f (export "lex-rule-digit-16/a-f") i32 (i32.const 173))

 (start $init)
 (func $init
   (table.set $lexical-rules (global.get $lex-rule-token)                           (ref.func $lex-match-token))
   (table.set $lexical-rules (global.get $lex-rule-token/group-1)                   (ref.func $lex-match-token/group-1))
   (table.set $lexical-rules (global.get $lex-rule-token/group-2)                   (ref.func $lex-match-token/group-2))
   (table.set $lexical-rules (global.get $lex-rule-token-char)                      (ref.func $lex-match-token-char))
   (table.set $lexical-rules (global.get $lex-rule-token-string)                    (ref.func $lex-match-token-string))
   (table.set $lexical-rules (global.get $lex-rule-delimiter)                       (ref.func $lex-match-delimiter))
   (table.set $lexical-rules (global.get $lex-rule-delimiter-char)                  (ref.func $lex-match-delimiter-char))
   (table.set $lexical-rules (global.get $lex-rule-intraline-whitespace)            (ref.func $lex-match-intraline-whitespace))
   (table.set $lexical-rules (global.get $lex-rule-whitespace)                      (ref.func $lex-match-whitespace))
   (table.set $lexical-rules (global.get $lex-rule-vertical-line)                   (ref.func $lex-match-vertical-line))
   (table.set $lexical-rules (global.get $lex-rule-line-ending)                     (ref.func $lex-match-line-ending))
   (table.set $lexical-rules (global.get $lex-rule-line-ending-char)                (ref.func $lex-match-line-ending-char))
   (table.set $lexical-rules (global.get $lex-rule-dos-line-ending)                 (ref.func $lex-match-dos-line-ending))
   (table.set $lexical-rules (global.get $lex-rule-comment)                         (ref.func $lex-match-comment))
   (table.set $lexical-rules (global.get $lex-rule-simple-comment)                  (ref.func $lex-match-simple-comment))
   (table.set $lexical-rules (global.get $lex-rule-semicolon)                       (ref.func $lex-match-semicolon))
   (table.set $lexical-rules (global.get $lex-rule-simple-comment-continuation)     (ref.func $lex-match-simple-comment-continuation))
   (table.set $lexical-rules (global.get $lex-rule-datum-comment)                   (ref.func $lex-match-datum-comment))
   (table.set $lexical-rules (global.get $lex-rule-begin-datum-comment)             (ref.func $lex-match-begin-datum-comment))
   (table.set $lexical-rules (global.get $lex-rule-nested-comment)                  (ref.func $lex-match-nested-comment))
   (table.set $lexical-rules (global.get $lex-rule-begin-nested-comment)            (ref.func $lex-match-begin-nested-comment))
   (table.set $lexical-rules (global.get $lex-rule-comment-continuations)           (ref.func $lex-match-comment-continuations))
   (table.set $lexical-rules (global.get $lex-rule-end-nested-comment)              (ref.func $lex-match-end-nested-comment))
   (table.set $lexical-rules (global.get $lex-rule-comment-text)                    (ref.func $lex-match-comment-text))
   (table.set $lexical-rules (global.get $lex-rule-nested-comment-delimiters)       (ref.func $lex-match-nested-comment-delimiters))
   (table.set $lexical-rules (global.get $lex-rule-comment-continuation)            (ref.func $lex-match-comment-continuation))
   (table.set $lexical-rules (global.get $lex-rule-directive)                       (ref.func $lex-match-directive))
   (table.set $lexical-rules (global.get $lex-rule-atmosphere)                      (ref.func $lex-match-atmosphere))
   (table.set $lexical-rules (global.get $lex-rule-intertoken-space)                (ref.func $lex-match-intertoken-space))
   (table.set $lexical-rules (global.get $lex-rule-identifier)                      (ref.func $lex-match-identifier))
   (table.set $lexical-rules (global.get $lex-rule-ordinary-identifier)             (ref.func $lex-match-ordinary-identifier))
   (table.set $lexical-rules (global.get $lex-rule-subsequents)                     (ref.func $lex-match-subsequents))
   (table.set $lexical-rules (global.get $lex-rule-vertical-line-quoted-symbol)     (ref.func $lex-match-vertical-line-quoted-symbol))
   (table.set $lexical-rules (global.get $lex-rule-symbol-elements)                 (ref.func $lex-match-symbol-elements))
   (table.set $lexical-rules (global.get $lex-rule-initial)                         (ref.func $lex-match-initial))
   (table.set $lexical-rules (global.get $lex-rule-letter)                          (ref.func $lex-match-letter))
   (table.set $lexical-rules (global.get $lex-rule-lowercase-letter)                (ref.func $lex-match-lowercase-letter))
   (table.set $lexical-rules (global.get $lex-rule-uppercase-letter)                (ref.func $lex-match-uppercase-letter))
   (table.set $lexical-rules (global.get $lex-rule-special-initial)                 (ref.func $lex-match-special-initial))
   (table.set $lexical-rules (global.get $lex-rule-subsequent)                      (ref.func $lex-match-subsequent))
   (table.set $lexical-rules (global.get $lex-rule-digit)                           (ref.func $lex-match-digit))
   (table.set $lexical-rules (global.get $lex-rule-hex-digit)                       (ref.func $lex-match-hex-digit))
   (table.set $lexical-rules (global.get $lex-rule-hex-digit/alphabetic)            (ref.func $lex-match-hex-digit/alphabetic))
   (table.set $lexical-rules (global.get $lex-rule-explicit-sign)                   (ref.func $lex-match-explicit-sign))
   (table.set $lexical-rules (global.get $lex-rule-special-subsequent)              (ref.func $lex-match-special-subsequent))
   (table.set $lexical-rules (global.get $lex-rule-special-subsequent/dot-or-at)    (ref.func $lex-match-special-subsequent/dot-or-at))
   (table.set $lexical-rules (global.get $lex-rule-inline-hex-escape)               (ref.func $lex-match-inline-hex-escape))
   (table.set $lexical-rules (global.get $lex-rule-inline-hex-escape-prefix)        (ref.func $lex-match-inline-hex-escape-prefix))
   (table.set $lexical-rules (global.get $lex-rule-hex-scalar-value)                (ref.func $lex-match-hex-scalar-value))
   (table.set $lexical-rules (global.get $lex-rule-mnemonic-escape)                 (ref.func $lex-match-mnemonic-escape))
   (table.set $lexical-rules (global.get $lex-rule-backslash)                       (ref.func $lex-match-backslash))
   (table.set $lexical-rules (global.get $lex-rule-mnemonic-escape-character)       (ref.func $lex-match-mnemonic-escape-character))
   (table.set $lexical-rules (global.get $lex-rule-peculiar-identifier)             (ref.func $lex-match-peculiar-identifier))
   (table.set $lexical-rules (global.get $lex-rule-peculiar-identifier/form-1)      (ref.func $lex-match-peculiar-identifier/form-1))
   (table.set $lexical-rules (global.get $lex-rule-peculiar-identifier/form-2)      (ref.func $lex-match-peculiar-identifier/form-2))
   (table.set $lexical-rules (global.get $lex-rule-dot)                             (ref.func $lex-match-dot))
   (table.set $lexical-rules (global.get $lex-rule-peculiar-identifier/form-3)      (ref.func $lex-match-peculiar-identifier/form-3))
   (table.set $lexical-rules (global.get $lex-rule-dot-subsequent)                  (ref.func $lex-match-dot-subsequent))
   (table.set $lexical-rules (global.get $lex-rule-sign-subsequent)                 (ref.func $lex-match-sign-subsequent))
   (table.set $lexical-rules (global.get $lex-rule-at-sign)                         (ref.func $lex-match-at-sign))
   (table.set $lexical-rules (global.get $lex-rule-symbol-element)                  (ref.func $lex-match-symbol-element))
   (table.set $lexical-rules (global.get $lex-rule-symbol-element/character)        (ref.func $lex-match-symbol-element/character))
   (table.set $lexical-rules (global.get $lex-rule-escaped-vertical-line)           (ref.func $lex-match-escaped-vertical-line))
   (table.set $lexical-rules (global.get $lex-rule-boolean)                         (ref.func $lex-match-boolean))
   (table.set $lexical-rules (global.get $lex-rule-character)                       (ref.func $lex-match-character))
   (table.set $lexical-rules (global.get $lex-rule-escaped-character)               (ref.func $lex-match-escaped-character))
   (table.set $lexical-rules (global.get $lex-rule-any-char)                        (ref.func $lex-match-any-char))
   (table.set $lexical-rules (global.get $lex-rule-character-prefix)                (ref.func $lex-match-character-prefix))
   (table.set $lexical-rules (global.get $lex-rule-named-character)                 (ref.func $lex-match-named-character))
   (table.set $lexical-rules (global.get $lex-rule-escaped-character-hex)           (ref.func $lex-match-escaped-character-hex))
   (table.set $lexical-rules (global.get $lex-rule-character-hex-prefix)            (ref.func $lex-match-character-hex-prefix))
   (table.set $lexical-rules (global.get $lex-rule-character-name)                  (ref.func $lex-match-character-name))
   (table.set $lexical-rules (global.get $lex-rule-character-name/group-1)          (ref.func $lex-match-character-name/group-1))
   (table.set $lexical-rules (global.get $lex-rule-character-name/group-2)          (ref.func $lex-match-character-name/group-2))
   (table.set $lexical-rules (global.get $lex-rule-character-name/group-3)          (ref.func $lex-match-character-name/group-3))
   (table.set $lexical-rules (global.get $lex-rule-string)                          (ref.func $lex-match-string))
   (table.set $lexical-rules (global.get $lex-rule-double-quote)                    (ref.func $lex-match-double-quote))
   (table.set $lexical-rules (global.get $lex-rule-string-elements)                 (ref.func $lex-match-string-elements))
   (table.set $lexical-rules (global.get $lex-rule-string-element)                  (ref.func $lex-match-string-element))
   (table.set $lexical-rules (global.get $lex-rule-string-element/character)        (ref.func $lex-match-string-element/character))
   (table.set $lexical-rules (global.get $lex-rule-string-element/character-escape) (ref.func $lex-match-string-element/character-escape))
   (table.set $lexical-rules (global.get $lex-rule-escaped-double-quote)            (ref.func $lex-match-escaped-double-quote))
   (table.set $lexical-rules (global.get $lex-rule-escaped-backslash)               (ref.func $lex-match-escaped-backslash))
   (table.set $lexical-rules (global.get $lex-rule-escaped-line-ending)             (ref.func $lex-match-escaped-line-ending))
   (table.set $lexical-rules (global.get $lex-rule-some-intraline-whitespace)       (ref.func $lex-match-some-intraline-whitespace))
   (table.set $lexical-rules (global.get $lex-rule-number)                          (ref.func $lex-match-number))
   (table.set $lexical-rules (global.get $lex-rule-num-2)                           (ref.func $lex-match-num-2))
   (table.set $lexical-rules (global.get $lex-rule-num-8)                           (ref.func $lex-match-num-8))
   (table.set $lexical-rules (global.get $lex-rule-num-10)                          (ref.func $lex-match-num-10))
   (table.set $lexical-rules (global.get $lex-rule-num-16)                          (ref.func $lex-match-num-16))
   (table.set $lexical-rules (global.get $lex-rule-complex-16)                      (ref.func $lex-match-complex-16))
   (table.set $lexical-rules (global.get $lex-rule-complex-10)                      (ref.func $lex-match-complex-10))
   (table.set $lexical-rules (global.get $lex-rule-complex-8)                       (ref.func $lex-match-complex-8))
   (table.set $lexical-rules (global.get $lex-rule-complex-2)                       (ref.func $lex-match-complex-2))
   (table.set $lexical-rules (global.get $lex-rule-simple-im)                       (ref.func $lex-match-simple-im))
   (table.set $lexical-rules (global.get $lex-rule-unit-im)                         (ref.func $lex-match-unit-im))
   (table.set $lexical-rules (global.get $lex-rule-complex-i)                       (ref.func $lex-match-complex-i))
   (table.set $lexical-rules (global.get $lex-rule-infnan-im)                       (ref.func $lex-match-infnan-im))
   (table.set $lexical-rules (global.get $lex-rule-complex-16/group-1)              (ref.func $lex-match-complex-16/group-1))
   (table.set $lexical-rules (global.get $lex-rule-complex-10/group-1)              (ref.func $lex-match-complex-10/group-1))
   (table.set $lexical-rules (global.get $lex-rule-complex-8/group-1)               (ref.func $lex-match-complex-8/group-1))
   (table.set $lexical-rules (global.get $lex-rule-complex-2/group-1)               (ref.func $lex-match-complex-2/group-1))
   (table.set $lexical-rules (global.get $lex-rule-complex-polar-16)                (ref.func $lex-match-complex-polar-16))
   (table.set $lexical-rules (global.get $lex-rule-complex-polar-10)                (ref.func $lex-match-complex-polar-10))
   (table.set $lexical-rules (global.get $lex-rule-complex-polar-8)                 (ref.func $lex-match-complex-polar-8))
   (table.set $lexical-rules (global.get $lex-rule-complex-polar-2)                 (ref.func $lex-match-complex-polar-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-infnan-im-16)            (ref.func $lex-match-complex-infnan-im-16))
   (table.set $lexical-rules (global.get $lex-rule-complex-infnan-im-10)            (ref.func $lex-match-complex-infnan-im-10))
   (table.set $lexical-rules (global.get $lex-rule-complex-infnan-im-8)             (ref.func $lex-match-complex-infnan-im-8))
   (table.set $lexical-rules (global.get $lex-rule-complex-infnan-im-2)             (ref.func $lex-match-complex-infnan-im-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-16/group-2)              (ref.func $lex-match-complex-16/group-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-10/group-2)              (ref.func $lex-match-complex-10/group-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-8/group-2)               (ref.func $lex-match-complex-8/group-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-2/group-2)               (ref.func $lex-match-complex-2/group-2))
   (table.set $lexical-rules (global.get $lex-rule-full-complex-16)                 (ref.func $lex-match-full-complex-16))
   (table.set $lexical-rules (global.get $lex-rule-full-complex-10)                 (ref.func $lex-match-full-complex-10))
   (table.set $lexical-rules (global.get $lex-rule-full-complex-8)                  (ref.func $lex-match-full-complex-8))
   (table.set $lexical-rules (global.get $lex-rule-full-complex-2)                  (ref.func $lex-match-full-complex-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-unit-im-16)              (ref.func $lex-match-complex-unit-im-16))
   (table.set $lexical-rules (global.get $lex-rule-complex-unit-im-10)              (ref.func $lex-match-complex-unit-im-10))
   (table.set $lexical-rules (global.get $lex-rule-complex-unit-im-8)               (ref.func $lex-match-complex-unit-im-8))
   (table.set $lexical-rules (global.get $lex-rule-complex-unit-im-2)               (ref.func $lex-match-complex-unit-im-2))
   (table.set $lexical-rules (global.get $lex-rule-complex-im-only-16)              (ref.func $lex-match-complex-im-only-16))
   (table.set $lexical-rules (global.get $lex-rule-complex-im-only-10)              (ref.func $lex-match-complex-im-only-10))
   (table.set $lexical-rules (global.get $lex-rule-complex-im-only-8)               (ref.func $lex-match-complex-im-only-8))
   (table.set $lexical-rules (global.get $lex-rule-complex-im-only-2)               (ref.func $lex-match-complex-im-only-2))
   (table.set $lexical-rules (global.get $lex-rule-real-16)                         (ref.func $lex-match-real-16))
   (table.set $lexical-rules (global.get $lex-rule-real-10)                         (ref.func $lex-match-real-10))
   (table.set $lexical-rules (global.get $lex-rule-real-8)                          (ref.func $lex-match-real-8))
   (table.set $lexical-rules (global.get $lex-rule-real-2)                          (ref.func $lex-match-real-2))
   (table.set $lexical-rules (global.get $lex-rule-signed-real-16)                  (ref.func $lex-match-signed-real-16))
   (table.set $lexical-rules (global.get $lex-rule-signed-real-10)                  (ref.func $lex-match-signed-real-10))
   (table.set $lexical-rules (global.get $lex-rule-signed-real-8)                   (ref.func $lex-match-signed-real-8))
   (table.set $lexical-rules (global.get $lex-rule-signed-real-2)                   (ref.func $lex-match-signed-real-2))
   (table.set $lexical-rules (global.get $lex-rule-ureal-16)                        (ref.func $lex-match-ureal-16))
   (table.set $lexical-rules (global.get $lex-rule-ureal-10)                        (ref.func $lex-match-ureal-10))
   (table.set $lexical-rules (global.get $lex-rule-ureal-8)                         (ref.func $lex-match-ureal-8))
   (table.set $lexical-rules (global.get $lex-rule-ureal-2)                         (ref.func $lex-match-ureal-2))
   (table.set $lexical-rules (global.get $lex-rule-urational-16)                    (ref.func $lex-match-urational-16))
   (table.set $lexical-rules (global.get $lex-rule-urational-10)                    (ref.func $lex-match-urational-10))
   (table.set $lexical-rules (global.get $lex-rule-urational-8)                     (ref.func $lex-match-urational-8))
   (table.set $lexical-rules (global.get $lex-rule-urational-2)                     (ref.func $lex-match-urational-2))
   (table.set $lexical-rules (global.get $lex-rule-slash)                           (ref.func $lex-match-slash))
   (table.set $lexical-rules (global.get $lex-rule-decimal-10)                      (ref.func $lex-match-decimal-10))
   (table.set $lexical-rules (global.get $lex-rule-decimal-10-forms)                (ref.func $lex-match-decimal-10-forms))
   (table.set $lexical-rules (global.get $lex-rule-dot-digits-10)                   (ref.func $lex-match-dot-digits-10))
   (table.set $lexical-rules (global.get $lex-rule-digits-10)                       (ref.func $lex-match-digits-10))
   (table.set $lexical-rules (global.get $lex-rule-digits-dot-digits-10)            (ref.func $lex-match-digits-dot-digits-10))
   (table.set $lexical-rules (global.get $lex-rule-digits-10?)                      (ref.func $lex-match-digits-10?))
   (table.set $lexical-rules (global.get $lex-rule-uinteger-16)                     (ref.func $lex-match-uinteger-16))
   (table.set $lexical-rules (global.get $lex-rule-uinteger-10)                     (ref.func $lex-match-uinteger-10))
   (table.set $lexical-rules (global.get $lex-rule-uinteger-8)                      (ref.func $lex-match-uinteger-8))
   (table.set $lexical-rules (global.get $lex-rule-uinteger-2)                      (ref.func $lex-match-uinteger-2))
   (table.set $lexical-rules (global.get $lex-rule-prefix-16)                       (ref.func $lex-match-prefix-16))
   (table.set $lexical-rules (global.get $lex-rule-prefix-10)                       (ref.func $lex-match-prefix-10))
   (table.set $lexical-rules (global.get $lex-rule-prefix-8)                        (ref.func $lex-match-prefix-8))
   (table.set $lexical-rules (global.get $lex-rule-prefix-2)                        (ref.func $lex-match-prefix-2))
   (table.set $lexical-rules (global.get $lex-rule-infnan)                          (ref.func $lex-match-infnan))
   (table.set $lexical-rules (global.get $lex-rule-inf-or-nan)                      (ref.func $lex-match-inf-or-nan))
   (table.set $lexical-rules (global.get $lex-rule-suffix)                          (ref.func $lex-match-suffix))
   (table.set $lexical-rules (global.get $lex-rule-suffix-sequence)                 (ref.func $lex-match-suffix-sequence))
   (table.set $lexical-rules (global.get $lex-rule-exponent-marker)                 (ref.func $lex-match-exponent-marker))
   (table.set $lexical-rules (global.get $lex-rule-sign)                            (ref.func $lex-match-sign))
   (table.set $lexical-rules (global.get $lex-rule-exactness)                       (ref.func $lex-match-exactness))
   (table.set $lexical-rules (global.get $lex-rule-radix-2)                         (ref.func $lex-match-radix-2))
   (table.set $lexical-rules (global.get $lex-rule-radix-8)                         (ref.func $lex-match-radix-8))
   (table.set $lexical-rules (global.get $lex-rule-radix-10)                        (ref.func $lex-match-radix-10))
   (table.set $lexical-rules (global.get $lex-rule-radix-16)                        (ref.func $lex-match-radix-16))
   (table.set $lexical-rules (global.get $lex-rule-digit-2)                         (ref.func $lex-match-digit-2))
   (table.set $lexical-rules (global.get $lex-rule-digit-8)                         (ref.func $lex-match-digit-8))
   (table.set $lexical-rules (global.get $lex-rule-digit-10)                        (ref.func $lex-match-digit))
   (table.set $lexical-rules (global.get $lex-rule-digit-16)                        (ref.func $lex-match-digit-16))
   (table.set $lexical-rules (global.get $lex-rule-digit-16/A-F)                    (ref.func $lex-match-digit-16/A-F))
   (table.set $lexical-rules (global.get $lex-rule-digit-16/a-f)                    (ref.func $lex-match-digit-16/a-f))))
