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

def test_parse_decimal():

    init_test()

    test_cases = [
        '1e0',
        '1.',
        '1.0',
        '1.00',
        '0.1',
        '.3333',
        '6553.6',
        str(math.pi),
        '6.02e+23',
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

    for src in test_cases:
        init_parser()
        value = parse_test(src)

        assert is_inexact(value)
        # todo: (big) integer multiplication and division will make this more
        # accurate.  See parse-decimal in parse.wam
        # assert get_boxed_f64(value) == float(src)
        assert get_boxed_f64(value) == pytest.approx(float(src), rel=1e-15)


# todo: test exact/inexact
# todo: test small integer vs i64 vs integer
