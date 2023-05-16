import pytest

from util import create_test_string, format_addr

from modules.debug.block_mgr import *
from modules.debug.bytevectors import *
from modules.debug.chars import *
from modules.debug.lex import *
from modules.debug.lex_r7rs import *
from modules.debug.numbers import *
from modules.debug.pairs import *
from modules.debug.strings import *
from modules.debug.symbols import *
from modules.debug.parse import *

NULL = NULL.value

def parse_test(src):

    s = create_test_string(src)
    text = get_string_addr(s)
    end = text + get_string_size(s)

    return parse(text, end)


def init_test():
    init_pairs()
    init_blockset_manager()
    init_strings()
    init_lex_r7rs()
    init_symbols()
    init_parse()

def test_init():
    init_test()

def test_init_parser():
    init_test()
    init_parser()

    assert ctx_stack.value != NULL

    ctx = get_pair_car(ctx_stack.value)
    value = get_bytevector_i32(ctx, ctx_value_offset.value)
    assert get_pair_car(value) == NULL
    assert get_pair_cdr(value) == NULL

def test_parse_empty():
    init_test()
    init_parser()

    assert parse_test('') == error_incomplete_input.value

def test_parse_symbol():
    init_test()
    init_parser()

    src = 'a'
    assert parse_test(src) == tag_symbol.value | inter_symbol(create_test_string(src))

def test_parse_binary_small_integer():

    init_test()

    for i in range(-10, 11):
        init_parser()
        src = f'#b{i:b}'
        assert parse_test(src) >> tag_size_bits.value == i

def test_parse_rational_2():

    init_test()

    for n in range(-4, 5):
        for d in range(1, 4):
            init_parser()
            src = f'#b{n:b}/{d:b}'

            value = parse_test(src)
            assert is_rational(value)

def test_parse_binary_full_complex():

    init_test()

    for re in range(-10, 11):
        for im in range(-10, 11):
            init_parser()
            src = f'#b{re:b}{im:+b}i'
            value = parse_test(src)
            assert is_complex(value)
            assert real_part(value) >> tag_size_bits.value == re
            assert imag_part(value) >> tag_size_bits.value == im

def test_parse_binary_complex_polar():

    init_test()

    for m in range(0, 5):
        init_parser()
        src = f'#b{m:b}@0'
        value = parse_test(src)
        assert is_complex(value)

        re = real_part(value)
        assert is_inexact(re)
        assert get_boxed_f64(re) == pytest.approx(m)

        im = imag_part(value)
        assert is_inexact(im)
        assert get_boxed_f64(im) == pytest.approx(0)

    for m in range(0, 5):
        init_parser()
        src = f'#b{m:b}@{11:b}/{7:b}'
        value = parse_test(src)
        assert is_complex(value)

        re = real_part(value)
        assert is_inexact(re)
        assert get_boxed_f64(re) == pytest.approx(0, abs=1e-2) # 22/7 is good to 2 decimal places

        im = imag_part(value)
        assert is_inexact(im)
        assert get_boxed_f64(im) == pytest.approx(m, abs=1e-2)
