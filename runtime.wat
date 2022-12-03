(module
  (memory (export "mem") 4)

  (global $word_size i32 i32.const 4)

  (global $value_data_mask          i32 i32.const 0xfffffff0)
  (global $value_type_mask          i32 i32.const 0xf)
  (global $value_type_bits          i32 i32.const 4)

  (global $value_type_small_integer i32 i32.const 0x0)
  (global $value_type_pair          i32 i32.const 0x1)
  (global $value_type_vector        i32 i32.const 0x2)
  (global $value_type_character     i32 i32.const 0x3)
  (global $value_type_symbol        i32 i32.const 0x4)
  (global $value_type_singleton     i32 i32.const 0xf)

  (global $pair_next_free_id (mut i32) i32.const 0)
  (global $pair_size i32 i32.const 8)

  (global $vector_index          (mut i32) i32.const 0x10000)
  (global $vector_data           (mut i32) i32.const 0x11000)
  (global $vector_next_free_id   (mut i32) i32.const 0)
  (global $vector_next_free_data (mut i32) i32.const 0)
  (global $vector_max_id         (mut i32) i32.const 512)

  (global $vector_entry_size   (mut i32) i32.const 8)

  (global $symbol_index          (mut i32) i32.const 0x20000)
  (global $symbol_data           (mut i32) i32.const 0x21000)
  (global $symbol_next_free_id   (mut i32) i32.const 0)
  (global $symbol_next_free_data (mut i32) i32.const 0)
  (global $symbol_max_id         (mut i32) i32.const 512)

  (global $symbol_entry_size   (mut i32) i32.const 8)

  ;; singletons
  (global $false (export "FALSE") i32 i32.const 0x0000000f)
  (global $null  (export "NULL")  i32 i32.const 0xffffffff)
  (global $true  (export "TRUE")  i32 i32.const 0x0000001f)

  (global $input_buffer  (export "input_buffer")  i32 i32.const 0x30000)
  (global $output_buffer (export "output_buffer") i32 i32.const 0x34000)
  (global $error_buffer  (export "error_buffer")  i32 i32.const 0x38000)

  (global $input_buffer_size  (export "input_buffer_size")  i32 i32.const 0x4000)
  (global $output_buffer_size (export "output_buffer_size") i32 i32.const 0x4000)
  (global $error_buffer_size  (export "error_buffer_size")  i32 i32.const 0x4000)

  (global $input_length  (export "input_length")  (mut i32) i32.const 0)
  (global $output_length (export "output_length") (mut i32) i32.const 0)
  (global $error_length  (export "error_length")  (mut i32) i32.const 0)

  (global $input_point  (export "input_point")  (mut i32) i32.const 0)
  (global $output_point (export "output_point") (mut i32) i32.const 0)
  (global $error_point  (export "error_point")  (mut i32) i32.const 0)

  (global $token_type_open_paren  i32 i32.const 0)
  (global $token_type_close_paren i32 i32.const 1)
  (global $token_type_atom        i32 i32.const 2)
  (global $token_type_eof         i32 i32.const 3)

  (global $char_line_feed       i32 i32.const 10)
  (global $char_carriage_return i32 i32.const 13)
  (global $char_space           i32 i32.const 32)
  (global $char_double_quote    i32 i32.const 34)
  (global $char_open_paren      i32 i32.const 40)
  (global $char_close_paren     i32 i32.const 41)
  (global $char_semicolon       i32 i32.const 59)
  (global $char_backslash       i32 i32.const 92)

  (global $error_code           (export "error-code") (mut i32) i32.const 0)
  (global $error_pair_expected  (export "error:pair-expected")  i32 i32.const 1)
  (global $error_unexpected_eof (export "error:unexpected-eof") i32 i32.const 2)

  (start $init)
  (func $init (export "init")
        i32.const 0
        i32.const 0xff
        i32.const 0xffff
        memory.fill)

  (func $string_eq (export "string_eq")
    (param $s_1 i32)
    (param $l_1 i32)
    (param $s_2 i32)
    (param $l_2 i32)
    (result i32)

    (local $_i i32)

    i32.const 0
    local.set $_i

    loop $again (result i32)

      local.get $l_1
      local.get $_i
      i32.eq

      local.get $l_2
      local.get $_i
      i32.eq

      i32.or
      if
        local.get $l_1
        local.get $l_2
        i32.eq
        return
      end

      local.get $s_1
      i32.load8_u

      local.get $s_2
      i32.load8_u

      i32.ne
      if
        i32.const 0
        return
      end

      local.get $_i
      i32.const 1
      i32.add
      local.set $_i

      local.get $s_1
      i32.const 1
      i32.add
      local.set $s_1

      local.get $s_2
      i32.const 1
      i32.add
      local.set $s_2

      br $again

    end)

  (func $make_value (param i32 i32) (result i32)
    local.get 0
    global.get $value_type_bits
    i32.shl
    local.get 1
    i32.or)

  (func $value_type (param i32) (result i32)
    local.get 0
    global.get $value_type_mask
    i32.and)

  (func $value_data (param i32) (result i32)
    local.get 0
    global.get $value_data_mask
    i32.and
    global.get $value_type_bits
    i32.shr_u)

  (func $is_pair (export "is_pair") (param i32) (result i32)
    local.get 0
    call $value_type
    global.get $value_type_pair
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
    global.set $error_code
    unreachable
    end)

  (func $deref_pair (param i32) (result i32)
    local.get 0
    global.get $pair_size
    i32.mul)

  (func $pair_addr (param i32) (result i32)

    local.get 0
    call $is_pair
    global.get $error_pair_expected
    call $assert

    local.get 0
    call $value_data
    call $deref_pair)

  (func $next_pair_id (result i32)
    (local $new_pair_id i32)
    global.get $pair_next_free_id
    local.tee $new_pair_id

    i32.const 1
    i32.add
    global.set $pair_next_free_id

    local.get $new_pair_id)

  (func $pair (export "cons") (param i32 i32) (result i32)
    (local $new_pair_addr i32)
    (local $new_pair_id i32)

    call $next_pair_id
    local.tee $new_pair_id

    call $deref_pair
    local.tee $new_pair_addr

    local.get 0
    i32.store

    local.get $new_pair_addr
    global.get $word_size
    i32.add
    local.get 1
    i32.store

    local.get $new_pair_id
    global.get $value_type_pair
    call $make_value)

  (func $car (export "car") (param i32) (result i32)
    local.get 0
    call $pair_addr
    i32.load)

  (func $cdr (export "cdr") (param i32) (result i32)
    local.get 0
    call $pair_addr
    global.get $word_size
    i32.add
    i32.load)

  (func $deref_vector (param $id i32) (result i32)
    local.get $id
    global.get $vector_entry_size
    i32.mul

    global.get $vector_index
    i32.add)

  (func $next_vector_id (result i32)

    global.get $vector_next_free_id
    global.get $vector_next_free_id

    i32.const 1
    i32.add
    global.set $vector_next_free_id)

  (func $vector_alloc (param $size i32) (result i32)

    global.get $vector_next_free_data
    global.get $vector_next_free_data

    local.get $size
    i32.add
    global.set $vector_next_free_data

    global.get $word_size
    i32.mul

    global.get $vector_data
    i32.add)

  (func $fill_vector_elements
    (param $elems i32)
    (param $size i32)
    (param $value i32)


    (local $_elem i32)
    (local $_end i32)

    local.get $size
    global.get $word_size
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
      global.get $word_size
      i32.add
      local.tee $_elem

      local.get $_end
      i32.lt_u
      br_if $again

    end)

  (func $make_vector (export "make_vector")
    (param $size i32)
    (param $init_value i32)
    (result i32)

    (local $_id    i32)
    (local $_addr  i32)
    (local $_size  i32)
    (local $_elems i32)

    call $next_vector_id
    local.tee $_id

    call $deref_vector
    local.tee $_addr

    local.get $size
    call $vector_alloc
    local.tee $_elems

    ;; stores the vector address in the first word of the vector index record
    i32.store

    ;; compute address of the length field of the vector index record
    local.get $_addr
    global.get $word_size
    i32.add

    ;; store the vector length in the second word of the vector
    local.get $size
    i32.store

    local.get $_elems
    local.get $size
    local.get $init_value
    call $fill_vector_elements

    local.get $_id
    global.get $value_type_vector
    call $make_value)

  (func $vector_ref (export "vector_ref")
    (param $v i32)
    (param $i i32)
    (result i32)

    local.get $v
    call $deref_vector
    i32.load
    local.get $i
    global.get $word_size
    i32.mul
    i32.add
    i32.load)

  (func $vector_set (export "vector_set")
    (param $v i32)
    (param $i i32)
    (param $x i32)

    local.get $v
    call $deref_vector
    i32.load
    local.get $i
    global.get $word_size
    i32.mul
    i32.add
    local.get $x
    i32.store)

  (func $deref_symbol (param $id i32) (result i32)
    local.get $id
    global.get $symbol_entry_size
    i32.mul

    global.get $symbol_index
    i32.add)

  (func $symbol_name (export "symbol_name")
    (param $id i32)
    (result i32 i32)

    (local $_addr i32)

    local.get $id
    call $deref_symbol
    local.tee $_addr
    i32.load
    local.get $_addr
    global.get $word_size
    i32.add
    i32.load)

  (func $find_symbol (export "find_symbol")
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
      call $symbol_name
      call $string_eq
      if
        local.get $_id
        return
      end

      local.get $_id
      global.get $symbol_next_free_id
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

  (func $next_symbol_id (result i32)

    global.get $symbol_next_free_id
    global.get $symbol_next_free_id

    i32.const 1
    i32.add
    global.set $symbol_next_free_id)

  (func $symbol_alloc (param $length i32) (result i32)

    global.get $symbol_next_free_data
    global.get $symbol_next_free_data

    local.get $length
    i32.add
    global.set $symbol_next_free_data

    global.get $symbol_data
    i32.add)

  (func $make_symbol (export "make_symbol")
    (param $str i32)
    (param $length i32)
    (result i32)

    (local $_id    i32)
    (local $_addr  i32)
    (local $_name  i32)

    call $next_symbol_id
    local.tee $_id

    call $deref_symbol
    local.tee $_addr

    local.get $length
    call $symbol_alloc
    local.tee $_name

    ;; stores the symbol name address in the first word of the symbol index record
    i32.store

    ;; compute address of the length field of the symbol index record
    local.get $_addr
    global.get $word_size
    i32.add

    ;; store the symbol length in the second word of the symbol
    local.get $length
    i32.store

    local.get $length
    local.get $str
    local.get $_name
    memory.copy

    local.get $_id
    global.get $value_type_symbol
    call $make_value)

  (func $inter_symbol (export "inter_symbol")
    (param $str i32)
    (param $length i32)
    (result i32)

    (local $_id i32)

    local.get $str
    local.get $length
    call $find_symbol

    local.tee $_id
    if
      local.get $_id
      return
    end

    local.get $str
    local.get $length
    call $make_symbol)

  (func $is_whitespace_char (param $c i32) (result i32)
    local.get $c
    global.get $char_space
    i32.le_u)

  (func $skip_whitespace
    loop $again
      call $is_at_eof
      if
        return
      end

      call $peek_char
      call $is_whitespace_char
      if
        call $advance_char
        br $again
      end
      end)

  (func $is_line_break_char (param $c i32) (result i32)
    local.get $c
    global.get $char_line_feed
    i32.eq
    local.get $c
    global.get $char_carriage_return
    i32.eq
    i32.or)

  (func $skip_comment

    call $is_at_eof
    if
      return
    end

    call $peek_char
    global.get $char_semicolon
    i32.eq
    if
      call $advance_char

      loop $again
        call $is_at_eof
        if
          return
        end

        call $peek_char
        call $is_line_break_char
        i32.eqz
        if
          call $advance_char
          br $again
        end
      end
    end)

  (func $skip_comments_and_whitespace

    (local $_c i32)

    loop $again
      call $is_at_eof
      if
        return
      end

      call $peek_char
      local.tee $_c
      call $is_whitespace_char
      if
        call $skip_whitespace
        br $again
      end

      local.get $_c
      global.get $char_semicolon
      i32.eq
      if
        call $skip_comment
        br $again
      end
    end)

  (func $is_at_eof (result i32)
    global.get $input_point
    global.get $input_length
    i32.eq)

  (func $advance_char
    global.get $input_point
    global.get $input_length
    i32.lt_u
    global.get $error_unexpected_eof
    call $assert

    global.get $input_point
    i32.const 1
    i32.add
    global.set $input_point)

  (func $next_char (result i32)
    call $peek_char
    call $advance_char)

  (func $peek_char (result i32)
    global.get $input_point
    global.get $input_buffer
    i32.add
    i32.load8_u)

  (func $is_token_char (param $c i32) (result i32)
    local.get $c
    global.get $char_space
    i32.gt_u

    local.get $c
    global.get $char_open_paren
    i32.ne

    local.get $c
    global.get $char_close_paren
    i32.ne

    i32.and
    i32.and)

  (func $next_quoted_token (result i32 i32)
    (local $_c i32)

    loop $again
      call $next_char
      local.tee $_c
      global.get $char_double_quote
      i32.ne
      if
        local.get $_c
        global.get $char_backslash
        i32.eq
        if
          call $advance_char
        end

        br $again
      end
    end

    global.get $input_point
    global.get $token_type_atom)

  (func $next_simple_token (result i32 i32)

    loop $again
      call $peek_char
      call $is_token_char
      if
        call $advance_char
        call $is_at_eof
        i32.eqz
        if
          br $again
        end
      end
    end

    global.get $input_point
    global.get $token_type_atom)

  (func $next_delimiter_token
    (param $c i32)
    (result i32 i32)

    global.get $input_point
    local.get $c
    global.get $char_open_paren
    i32.eq
    if (result i32)
      global.get $token_type_open_paren
    else
      global.get $token_type_close_paren
    end)

  (func $next_token (export "next_token")
    (result i32 i32 i32)

    (local $_c i32)

    call $skip_comments_and_whitespace
    global.get $input_point

    call $is_at_eof
    if (result i32 i32)
      global.get $input_point
      global.get $token_type_eof

    else

      call $next_char
      local.tee $_c
      local.get $_c
      call $is_token_char
      if (param i32) (result i32 i32)
        global.get $char_double_quote
        i32.eq
        if (result i32 i32)
          call $next_quoted_token
        else
          call $next_simple_token
        end
      else
        call $next_delimiter_token
      end
    end))
