from util import format_addr
from modules.debug.block_mgr import *
from modules.debug.numbers import *
from modules.debug.pairs import *

NULL = NULL.value

def integer_to_int(x, log=False):
    v = 0

    for i in range(get_integer_size(x)):

        digit = get_integer_digit_i64(x, i)

        if digit < 0:
            digit += 1<<64

        if log:
            print(digit)

        v += digit << (64*i)

    return v

def int_to_integer(v):

    is_negative = v < 0

    if is_negative:
        v = -v

    size = 0
    w = v

    while w:
        size += 1
        w >>= 64

    x = alloc_integer(size)

    for i in range(size):

        digit = set_integer_i64_digit(x, i, v & ((1<<64)-1))

        v >>= 64

    if is_negative:
        negate_integer(x)

    return x

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
        x = int_to_integer(-(10**i))
        assert is_negative(x)
        f64 = coerce_integer_f64(x)
        assert f64 == -pow(10, i)

    for i in range(300):
        v = 10**i
        x = int_to_integer(v)
        f64 = coerce_integer_f64(x)
        assert f64 == float(v)

def test_is_zero_integer():

    init_test()

    for i in range(1, 16):
        x = make_integer(0, i)
        assert is_zero_integer(x)

        set_integer_i64_digit(x, i-1, 1)
        assert not is_zero_integer(x)

def test_get_integer_bit_size():

    init_test()

    x = make_integer_i64(0)
    assert get_integer_bit_size(x) == 0

    x = make_integer_i64(1)
    assert get_integer_bit_size(x) == 1

    x = make_integer_i64(2)
    assert get_integer_bit_size(x) == 2

    x = make_integer_i64(3)
    assert get_integer_bit_size(x) == 2

    x = make_integer_i64(4)
    assert get_integer_bit_size(x) == 3

    x = make_integer_i64(100)
    assert get_integer_bit_size(x) == 7

    x = make_integer_i64(0)
    set_integer_i32_digit(x, 1, 1)
    assert get_integer_bit_size(x) == 33

    x = make_integer(0, 2)
    set_integer_i32_digit(x, 3, 1)
    assert get_integer_bit_size(x) == 97

def test_normalize_number():

    init_test()

    x = make_integer(0, 1)
    y = normalize_number(x)
    assert y == 0

def test_normalize_integer():

    init_test()

    x = make_integer(0, 1)
    y = normalize_integer(x)
    assert y == 0

    for i in range(5):
        x = make_integer(10**i, 1)
        assert normalize_integer(x) >> 3 == 10**i

def test_integer_pow_10_constants():

    init_test()

    assert integer_to_int(integer_1e16.value)  == 10**16
    assert integer_to_int(integer_1e32.value)  == 10**32
    assert integer_to_int(integer_1e64.value)  == 10**64
    assert integer_to_int(integer_1e128.value) == 10**128
    assert integer_to_int(integer_1e256.value) == 10**256

def test_pow_10_integer():

    init_test()

    for i in range(500):
        x = pow_10_integer(i)
        assert integer_to_int(x) == 10**i

def test_quotient():

    init_test()

    x = make_integer(100000001, 1)
    y = make_small_integer(5)

    assert integer_to_int(quotient(x, y)) == 20000000

def test_gcd_integer():

    init_test()

    x = make_integer(602, 1)
    y = make_integer(100, 1)

    assert integer_to_int(gcd_integer(x, y)) == 2

    for i in range (1, 2):
      x = make_integer(95, 1)
      y = int_to_integer(10**i)
      d = gcd_integer(x, y)
      print(i, format_addr(d))
      assert integer_to_int(d) == 5

def test_integer_remainder():

    init_test()

    x = int_to_integer(95)
    y = int_to_integer(10)

    assert integer_to_int(integer_remainder(x, y)) == 5

    x = int_to_integer(10)
    y = int_to_integer(5)

    assert integer_to_int(integer_remainder(x, y)) == 0

    x = int_to_integer(10**201)
    y = make_integer(95, 1)

    assert integer_to_int(integer_remainder(x, y)) == 10**201 % 95

def test_integer_division():

    init_test()

    x = make_integer(100, 1)
    y = make_integer(5, 1)

    r, q = integer_division(x, y)

    assert integer_to_int(r) == 0
    assert integer_to_int(q) == 20

    x = int_to_integer(10**201)
    y = make_integer(95, 1)

    r, q = integer_division(x, y)

    assert integer_to_int(r) == 10**201 % 95
    assert integer_to_int(q) == 10**201 // 95

def test_divide_integer_digits():

    init_test()

    for i in range(1, 10):
        for j in range(1, i):
            x = int_to_integer(i-j)
            y = int_to_integer(j)
            print(i-j, j, end=' ')
            r, q = divide_integer_digits(x, y)

            print('q:', integer_to_int(q), 'r:', integer_to_int(r))
            assert integer_to_int(r) == (i-j) % j
            assert integer_to_int(q) == (i-j) // j

    for i in range(1, 100, 9):
        for j in range(1, i, 7):
            x = int_to_integer(i-j)
            y = int_to_integer(j)
            print(i-j, j, end=' ')
            r, q = divide_integer_digits(x, y)

            print('q:', integer_to_int(q), 'r:', integer_to_int(r))
            assert integer_to_int(r) == (i-j) % j
            assert integer_to_int(q) == (i-j) // j

    for i in range(1, 10000, 974):
        for j in range(1, i, 1031):
            x = int_to_integer(i-j)
            y = int_to_integer(j)
            print(i-j, j, end=' ')
            r, q = divide_integer_digits(x, y)

            print('q:', integer_to_int(q), 'r:', integer_to_int(r))
            assert integer_to_int(r) == (i-j) % j
            assert integer_to_int(q) == (i-j) // j

    for i in range(1, 100000000, 9745467):
        for j in range(1, i, 10311231):
            x = int_to_integer(i-j)
            y = int_to_integer(j)
            print(i-j, j, end=' ')
            r, q = divide_integer_digits(x, y)

            print('q:', integer_to_int(q), 'r:', integer_to_int(r))
            assert integer_to_int(r) == (i-j) % j
            assert integer_to_int(q) == (i-j) // j

    for i in range(1, 10000000000000000, 974546712345678):
        for j in range(1, i, 1031123112345678):
            x = int_to_integer(i-j)
            y = int_to_integer(j)
            print(i-j, j, end=' ')
            r, q = divide_integer_digits(x, y)

            print('q:', integer_to_int(q), 'r:', integer_to_int(r))
            assert integer_to_int(r) == (i-j) % j
            assert integer_to_int(q) == (i-j) // j

    x = int_to_integer(10**201)
    y = make_integer(95, 1)

    print('x:', get_integer_size(x))
    print('y:', get_integer_size(y))
    print('x bit size:', get_integer_bit_size(x))
    print('y bit size:', get_integer_bit_size(y))

    try:
        r, q = divide_integer_digits(x, y)

        assert integer_to_int(r) == 10**201 % 95
        assert integer_to_int(q) == 10**201 // 95

    except:
        h1 = p1.value
        h2 = p2.value
        h3 = p3.value

        while h1 != NULL:
            print('bit-place:', get_pair_car(h1))
            print('rem:', integer_to_int(get_pair_car(h2)))
            print('div:', integer_to_int(get_pair_car(h3)))
            print()

            h1 = get_pair_cdr(h1)
            h2 = get_pair_cdr(h2)
            h3 = get_pair_cdr(h3)

        raise

def test_subtract_integer_digits():

    init_test()

    x = make_integer(11, 1)
    y = make_integer(10, 1)

    assert integer_to_int(subtract_integer_digits(x, y)) == 1

    x = make_integer(100, 1)
    y = make_integer(80, 1)

    assert integer_to_int(subtract_integer_digits(x, y)) == 20

def test_set_integer_bit():

    init_test()

    x = make_integer(0, 1)
    set_integer_bit(x, 1)
    assert integer_to_int(x) == 2

def test_lt_integer():

    init_test()

    x = make_integer(11, 1)
    y = make_integer(10, 1)

    assert not lt_integer(x, y)

    x = make_integer(95, 1)
    y = int_to_integer(10**201)

    assert lt_integer(x, y)

def test_copy_integer():

    init_test()

    x = make_integer(11, 1)
    y = make_integer(10, 1)

    assert integer_to_int(copy_integer(x)) == 11
    assert integer_to_int(copy_integer(y)) == 10

def test_shift_integer():

    init_test()

    x = make_integer(5, 1)

    shift_integer(x, 1)
    assert integer_to_int(x) == 10

    x = make_integer(5, 1)

    shift_integer(x, 4)
    assert integer_to_int(x) == 80

    x = make_integer(80, 1)

    shift_integer(x, -2)
    assert integer_to_int(x) == 20

def test_shift_integer_left():

    init_test()

    for n in range(128):
        for k in range(1, n):
            for j in range(k+1, n):
                x = int_to_integer((1<<(n-k)) + (1<<(j-k)))
                shift_integer_left(x, k)
                assert integer_to_int(x) == (1<<n) + (1<<j)

def test_shift_integer_right():

    init_test()

    for n in range(128):
        for k in range(1, n):
            for j in range(k+1, n):
                x = int_to_integer((1<<n) + (1<<j))
                shift_integer_right(x, k)
                assert integer_to_int(x) == (1<<(n-k)) + (1<<(j-k))
