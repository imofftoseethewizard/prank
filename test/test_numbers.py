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

def test_negate_integer():

    init_test()

    n = make_integer(1, 1)

    set_integer_i32_digit(n, 0, 1)

    assert not is_negative(n)

    negate_integer(n)

    assert is_negative(n)

    n = make_integer(-1, 1)

    assert is_negative(n)

    negate_integer(n)

    assert not is_negative(n)

def test_negate_rational():

    init_test()

    n = make_rational(make_small_integer(1), make_small_integer(2))

    assert not is_negative(n)

    negate_number(n)

    assert is_negative(n)

def test_make_rational():

    init_test()

    n = make_rational(make_small_integer(1), make_small_integer(2))

    assert is_rational(n)
    assert denominator(n) == make_small_integer(2)
    assert numerator(n) == make_small_integer(1)

def test_make_complex_f64():

    init_test()

    n = make_complex(make_boxed_f64(1.0), make_boxed_f64(2.0))

    assert is_complex(n)
    assert is_inexact(real_part(n))
    assert is_inexact(imag_part(n))

def test_make_boxed_f64():

    init_test()

    for i in range(-5, 6):
        n = make_boxed_f64(1.0 * i)
        assert is_inexact(n)
        assert get_boxed_f64(n) == 1.0 * i

def test_coerce_integer_f64():

    init_test()

    assert coerce_integer_f64(make_integer(0, 1)) == 0.0

    for i in range(0, 63):
        x = make_integer(2**i, 1)
        assert coerce_integer_f64(x) == pow(2, i)

    for i in range(0, 18):
        x = make_integer(10**i, 1)
        assert coerce_integer_f64(x) == pow(10, i)

    for i in range(0, 18):
        x = make_integer(10**i, 1)
        negate_integer(x)
        assert coerce_integer_f64(x) == -pow(10, i)
