import pytest

import math

from util import create_test_string, format_addr

from modules.debug.block_mgr import *
from modules.debug.bytevectors import *
from modules.debug.chars import *
from modules.debug.lex import *
from modules.debug.lex_r7rs import *
from modules.debug.numbers import *
from modules.debug.pairs import *
from modules.debug.parse import *
from modules.debug.strings import *
from modules.debug.symbols import *
from modules.debug.vectors import *

from modules.debug import parse as parse_mod

NULL = NULL.value

def to_int(x):

    if is_small_integer(x):
        return x >> 3

    elif is_boxed_i64(x):
        return get_boxed_i64(x)

    elif is_rational(x) or is_complex(x) or is_boxed_f64(x):
        assert False

    else:
        return integer_to_int(x)

def integer_to_int(x):
    v = 0

    for i in range(get_integer_size(x)):

        digit = get_integer_digit_i64(x, i)

        if digit < 0:
            digit += 1<<64

        v += digit << (64*i)

    return v

def parse_test(src):

    s = create_test_string(src)
    text = get_string_addr(s)
    end = text + get_string_size(s)

    return parse(text, end)


def init_test():
    init_pairs()
    init_blockset_manager()
    init_bytevectors()
    init_vectors()
    init_numbers()
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

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_small_integer(radix, fmt):

    init_test()

    for i in range(-20, 21):
        init_parser()
        src = f'{radix}{{i:{fmt}}}'.format(i=i)
        print(src)
        assert parse_test(src) >> tag_size_bits.value == i

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_rational_2(radix, fmt):

    init_test()

    for n in range(-20, 21):
        for d in range(1, 20):
            init_parser()
            src = f'{radix}{{n:{fmt}}}/{{d:{fmt}}}'.format(n=n, d=d)

            value = parse_test(src)
            assert is_rational(value)

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_full_complex(radix, fmt):

    init_test()

    for re in range(-20, 21):
        for im in range(-20, 21):
            init_parser()
            src = f'{radix}{{re:{fmt}}}{{im:+{fmt}}}i'.format(re=re, im=im)
            value = parse_test(src)
            assert is_complex(value)
            assert real_part(value) >> tag_size_bits.value == re
            assert imag_part(value) >> tag_size_bits.value == im

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_polar(radix, fmt):

    init_test()

    for m in range(0, 5):
        init_parser()
        src = f'{radix}{{m:{fmt}}}@0'.format(m=m)
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
        src = f'{radix}{{m:{fmt}}}@{{n:{fmt}}}/{{d:{fmt}}}'.format(m=m, n=11, d=7)
        value = parse_test(src)
        assert is_complex(value)

        re = real_part(value)
        assert is_inexact(re)
        assert get_boxed_f64(re) == pytest.approx(0, abs=1e-2) # 22/7 is good to 2 decimal places

        im = imag_part(value)
        assert is_inexact(im)
        assert get_boxed_f64(im) == pytest.approx(m, abs=1e-2)

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_unit_im(radix, fmt):

    init_test()

    for re in range(-20, 21):
        init_parser()
        src = f'{radix}{{re:{fmt}}}+i'.format(re=re)
        value = parse_test(src)
        assert is_complex(value)
        assert real_part(value) >> tag_size_bits.value == re
        assert imag_part(value) >> tag_size_bits.value == 1

        init_parser()
        src = f'{radix}{{re:{fmt}}}-i'.format(re=re)
        value = parse_test(src)
        assert is_complex(value)
        assert real_part(value) >> tag_size_bits.value == re
        assert imag_part(value) >> tag_size_bits.value == -1

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_im_only(radix, fmt):

    init_test()

    for im in range(-20, 21):
        init_parser()
        src = f'{radix}{{im:+{fmt}}}i'.format(im=im)
        print(src)
        value = parse_test(src)
        assert is_complex(value)
        assert real_part(value) == 0
        assert imag_part(value) >> tag_size_bits.value == im

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_infnan_im(radix, fmt):

    init_test()

    for re in range(-20, 21):
        for sign in '+-':
            for im_val in ['inf', 'nan']:
                init_parser()
                src = f'{radix}{{re:{fmt}}}{{sign}}{{im_val}}.0i'.format(re=re, sign=sign, im_val=im_val)
                value = parse_test(src)
                assert is_complex(value)
                assert real_part(value) >> tag_size_bits.value == re

                im = imag_part(value)
                assert is_inexact(im)
                im_f64 = get_boxed_f64(im)

                if im_val == 'nan':
                    assert math.isnan(im_f64)
                else:
                    assert im_f64 == float(f'{sign}inf')

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_infnan_im(radix, fmt):

    init_test()

    for sign in '+-':
        for im_val in ['inf', 'nan']:
            init_parser()
            src = f'{radix}{{sign}}{{im_val}}.0i'.format(sign=sign, im_val=im_val)
            value = parse_test(src)
            assert is_complex(value)
            assert real_part(value) == 0

            im = imag_part(value)
            assert is_inexact(im)
            im_f64 = get_boxed_f64(im)

            if im_val == 'nan':
                assert math.isnan(im_f64)
            else:
                assert im_f64 == float(f'{sign}inf')

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_infnan(radix, fmt):

    init_test()

    for sign in '+-':
        for val in ['inf', 'nan']:
            init_parser()
            src = f'{radix}{{sign}}{{val}}.0'.format(sign=sign, val=val)
            value = parse_test(src)
            assert is_inexact(value)
            f64 = get_boxed_f64(value)

            if val == 'nan':
                assert math.isnan(f64)
            else:
                assert f64 == float(f'{sign}inf')

decimal_test_cases = [
    '1e0',
    '1.',
    '1.0',
    '1.00',
    '0.1',
    '.3333',
    '101.101',
    '655.36',
    '3.141592653589793',
    '6.02e+23',
    '95e-8',
    '95e-201',
    '1e-400',
    '1e+400',
    '29e6',
    '-10000000000000000000000000000000000000000000.0',
    '1.0e310',
    '1.0e-310',
    '-1.0e310',
    '-1.0e-310',
    '10000e307'
]

exact_decimal_test_values = [
    1,
    1,
    1,
    1,
    (1, 10),
    (3333, 10000),
    (101101, 1000),
    (16384, 25),
    (3141592653589793, 1000000000000000),
    602000000000000000000000,
    (19, 20000000),
    (19, 200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    (1, 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
    29000000,
    -10000000000000000000000000000000000000000000,
    10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
    (1, 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    -10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
    (-1, 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
]

def test_parse_exact_decimal():

    init_test()

    for src, value in zip(decimal_test_cases, exact_decimal_test_values):
        init_parser()
        src = '#e' + src
        print(src)
        try:
            result = parse_test(src)
            if type(value) == int:

                if is_small_integer(result):
                    assert result >> 3 == value

                elif is_boxed_i64(result):
                    assert get_boxed_i64(result) == value

                else:
                    i = 0

                    if value < 0:
                        assert is_negative(result)
                        value = -value
                    else:
                        assert not is_negative(result)

                    while value:
                        digit_v = value & ((1<<64)-1)
                        digit_i = get_integer_digit_i64(result, i)
                        if digit_i < 0:
                            digit_i += 1<<64
                        assert digit_v == digit_i
                        i += 1
                        value >>= 64

            else:
                print(type(value), value)
                n, d = value
                assert is_rational(result)

                denom = denominator(result)
                num = numerator(result)

                if is_small_integer(num):
                    assert num >> 3 == n

                elif is_boxed_i64(num):
                    assert get_boxed_i64(num) == n

                else:
                    assert integer_to_int(num) == n

                if is_small_integer(denom):
                    assert denom >> 3 == d

                elif is_boxed_i64(denom):
                    assert get_boxed_i64(denom) == d

                else:
                    assert integer_to_int(denom) == d

        except:
            print('numbers:')
            print(hex(numbers.p1.value))
            print(hex(numbers.p2.value))
            print(hex(numbers.p3.value))
            print(hex(numbers.p4.value))
            print('parse:')
            print(hex(parse_mod.p1.value))
            print(hex(parse_mod.p2.value))
            print(hex(parse_mod.p3.value))
            print(hex(parse_mod.p4.value))
            raise

def test_parse_decimal():

    init_test()

    for src in decimal_test_cases:
        init_parser()
        print(src)
        value = parse_test(src)

        assert is_inexact(value)
        assert get_boxed_f64(value) == float(src)


def test_pow_10_integer():

    init_test()

    for i in range(5):
        x = pow_10_integer(i)
        assert get_integer_digit_i32(x, 0) == 10**i


def check_octal_integer(src_base):

    src = f'#o{src_base}'
    py_src = f'0o{src_base}'
    value = eval(py_src)
    init_parser()

    result = parse_test(src)

    try:
        assert to_int(result) == value

    except:
        print(src)
        print(py_src)
        print(format_addr(result))
        print(value)

        raise

def test_octal_integer():

    init_test()

    for i in range(1, 80):
        for d in range(8):
            check_octal_integer(str(d)*i)
            check_octal_integer(str(d)+'0'*(i-1))

def test_octal_number_forms():

    init_test()

    init_parser()
    result = parse_test('#i#o26/7')
    assert get_boxed_f64(result) == 0o26/7

# todo: test small integer vs i64 vs integer
