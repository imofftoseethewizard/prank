from util import format_addr
from modules.debug.block_mgr import *
from modules.debug.numbers import *
from modules.debug.pairs import *

NULL = NULL.value

def init_test():
    init_pairs()
    init_blockset_manager()
    init_numbers()

def test_init():
    init_test()

def test_alloc_integer():
    init_test()

    n = alloc_integer(1)

def test_get_integer_size():
    init_test()

    n = alloc_integer(1)
    assert get_integer_size(n) == 1

    n = alloc_integer(2)
    assert get_integer_size(n) == 2

    n = alloc_integer(20)
    assert get_integer_size(n) == 20

def test_alloc_integer_zero():

    init_test()

    n = alloc_integer(1)

    assert get_integer_digit_i32(n, 0) == 0
    assert get_integer_digit_i32(n, 1) == 0

    multiply_add_integer_i32(n, 0, 1)

    init_test()

    n = alloc_integer(1)

    assert get_integer_digit_i32(n, 0) == 0
    assert get_integer_digit_i32(n, 1) == 0

def test_multiply_add_1():

    init_test()

    n = alloc_integer(1)

    multiply_add_integer_i32(n, 0, 1)

    assert get_integer_digit_i32(n, 0) == 1
    assert get_integer_digit_i32(n, 1) == 0

def test_multiply_add_2():

    init_test()

    n = alloc_integer(1)

    multiply_add_integer_i32(n, 0, 1)
    multiply_add_integer_i32(n, 10, 5)

    assert get_integer_digit_i32(n, 1) == 0
    assert get_integer_digit_i32(n, 0) == 15

def test_multiply_add_carry_1():

    init_test()

    n = alloc_integer(1)

    multiply_add_integer_i32(n, 0, 0xffffffff)
    multiply_add_integer_i32(n, 1, 1)

    assert get_integer_digit_i32(n, 1) == 1
    assert get_integer_digit_i32(n, 0) == 0

def test_multiply_add_carry_2():

    init_test()

    n = alloc_integer(1)

    multiply_add_integer_i32(n, 0, 0x10000)
    multiply_add_integer_i32(n, 0x10000, 5)

    assert get_integer_digit_i32(n, 1) == 1
    assert get_integer_digit_i32(n, 0) == 5

def test_negate_1():

    init_test()

    n = alloc_integer(1)

    set_integer_i32_digit(n, 0, 1)
    negate_integer(n)

    assert get_integer_digit_i32(n, 1) == -1
    assert get_integer_digit_i32(n, 0) == -1

def test_negate_2():

    init_test()

    n = alloc_integer(1)

    set_integer_i32_digit(n, 0, -1)
    set_integer_i32_digit(n, 1, -1)
    negate_integer(n)

    assert get_integer_digit_i32(n, 1) == 0
    assert get_integer_digit_i32(n, 0) == 1

def test_negate_3():

    init_test()

    n = alloc_integer(1)

    set_integer_i32_digit(n, 0, 0xffff_ffff)
    set_integer_i32_digit(n, 1, 0x7fff_ffff)

    negate_integer(n)

    assert (get_integer_digit_i32(n, 1) & 0xffff_ffff) == 0x8000_0000
    assert get_integer_digit_i32(n, 0) == 1

    negate_integer(n)

    assert get_integer_digit_i32(n, 1) == 0x7fff_ffff
    assert get_integer_digit_i32(n, 0) == -1
