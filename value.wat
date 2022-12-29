(module

 ;;=============================================================================
 ;;
 ;; Values
 ;;
 ;; Each pair contains two values.  These are tagged to indicate what kind of
 ;; value they hold.  The tag occupies the low 3 bits of the value.
 ;;
 ;; The rationale for the tag assignments below follows from an attempt to
 ;; arrange small integer arithmetic and pair dereferencing as to be as
 ;; efficient as possible.
 ;;
 ;; Small integer considerations are that the small integer tag is 0, and that
 ;; the tag bits are in the low bits of the word.  Together these allow small
 ;; integer operations without any shifts or masking.
 ;;
 ;; The allowance for pairs is the 3 bit tag.  With 4 byte words, and therefore
 ;; 8 byte pairs, all pair addresses will have the lower 3 bits 0. Hence, to
 ;; transform a pair value to a pair address only requires a mask.
 ;;
 ;; Small integers are numbers that fit within 2^29, should an operation cause
 ;; an overflow, the value will be automatically promoted to a block value,
 ;; encoding the number as an arbitrary-precision integer.
 ;;
 ;; Blocks contain the address of a pair.  The first value in the pair contains
 ;; a type designator, the second value contains the address of a block in the
 ;; blockstore.  The pair referenced by a block value is the owner of the block
 ;; in the blockstore, and every block has exactly one such owner.  Some blocks
 ;; may be empty -- such as a vector of length zero -- in which case the block
 ;; address will be $null.  Type designators are a small enumeration which
 ;; includes values for bytearrays, numbers, strings, and vectors.
 ;;
 ;; Boxes contain the address of a pair, similar to blocks.  They also have a
 ;; type designator in the first value and an address in the second.  Currently,
 ;; the only purpose envisioned for these is to hold a weak reference.  Another
 ;; possibility would be an opaque 32-bit value from an external source.  This
 ;; would be unsafe to put in an ordinary pair, and much less efficient to store
 ;; in a bytearray. Small strings or bytearrays could also fit, packed as
 ;;
 ;;     0               1                | 0               1
 ;;     0123456789abcdef0123456789abcdef | 0123456789abcdef0123456789abcdef
 ;;     | type  | count | char1 | char2 |  | char3 | char4 | char5 | char6 |
 ;;
 ;; Procedures. TBD.
 ;;
 ;; A symbol is an index into the symbol table. The symbol table is a private
 ;; vector which contains string values, sorted lexicographically.
 ;;
 ;; Singletons are one of the following: #true, #false, #null, #eof-object

 (global $value-tag-mask  (export "tag-mask")  i32 (i32.const 0x00000007))
 (global $value-data-mask (export "data-mask") i32 (i32.const 0xfffffff8))

 (global $tag-small-integer (export "tag-small-integer") i32 (i32.const 0x00))
 (global $tag-block         (export "tag-block")         i32 (i32.const 0x01))
 (global $tag-box           (export "tag-box")           i32 (i32.const 0x02))
 (global $tag-char          (export "tag-char")          i32 (i32.const 0x03))
 (global $tag-pair          (export "tag-pair")          i32 (i32.const 0x04))
 (global $tag-procedure     (export "tag-procedure")     i32 (i32.const 0x05))
 (global $tag-symbol        (export "tag-symbol")        i32 (i32.const 0x06))
 (global $tag-singleton     (export "tag-singleton")     i32 (i32.const 0x07))

 ;; Singletons

 (global $eof            (export "#eof-object")    i32 (i32.const 0xeee00fff))
 (global $false          (export "#false")         i32 (i32.const 0x00000007))
 (global $null           (export "#null")          i32 (i32.const 0xffffffff))
 (global $true           (export "#true")          i32 (i32.const 0x0000000f))
 (global $type-bytearray (export "type-bytearray") i32 (i32.const 0x00010007))
 (global $type-number    (export "type-number")    i32 (i32.const 0x00010017))
 (global $type-string    (export "type-string")    i32 (i32.const 0x00010027))
 (global $type-vector    (export "type-vector")    i32 (i32.const 0x0001003f))

 (global $singleton-type-mask       (export "singleton-type-mask")       i32 (i32.const 0xffff0007))
 (global $singleton-type-null       (export "singleton-type-null")       i32 (i32.const 0xffff0007))
 (global $singleton-type-boolean    (export "singleton-type-boolean")    i32 (i32.const 0x00000007))
 (global $singleton-type-eof        (export "singleton-type-eof")        i32 (i32.const 0xeee00007))
 (global $singleton-type-block-type (export "singleton-type-block-type") i32 (i32.const 0x00010007))

 (func $get-value-tag (export "value-tag")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $value-tag-mask)))

 (func $get-value-data (export "value-data")
   (param $value i32)
   (result i32)
   (i32.and (local.get $value) (global.get $value-data-mask)))

 (func $make-value (export "make-value")
   (param $tag i32)
   (param $data i32)
   (result i32)
   (i32.or (local.get $tag) (local.get $data)))

 (func $is-pair-value (export "is-pair-value")
   (param $value i32)
   (result i32)
   (i32.eq (call $get-value-tag (local.get $value)) (global.get $tag-pair)))

 )
