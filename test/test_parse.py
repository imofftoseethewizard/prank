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

def test_parse_binary_full_complex():

    init_test()

    for re in range(-10, 11):
        for im in range(-10, 11):
            init_parser()
            src = f'#b{re:b}{im:+b}i'
            print(src)
            value = parse_test(src)
            print(format_addr(value))
            assert is_complex(value)
