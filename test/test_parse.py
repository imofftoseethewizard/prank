import pytest

import math
import struct

from util import create_test_string, format_addr

from modules.debug.block_mgr import *
from modules.debug.bytevectors import *
from modules.debug.chars import *
from modules.debug.lex import *
from modules.debug.lex_r7rs import *
from modules.debug.lists import *
from modules.debug.numbers import *
from modules.debug.pairs import *
from modules.debug.parse import *
from modules.debug.strings import *
from modules.debug.symbols import *
from modules.debug.vectors import *

from modules.debug import parse as parse_mod
from modules.debug import strings, symbols

NULL = NULL.value
TRUE = TRUE.value
FALSE = FALSE.value

def to_int(x):

    if is_small_integer(x):

        if x < 0:
            x += 1<<32

        return x >> 3

    elif is_boxed_i64(x):

        v = get_boxed_i64(x)

        return v

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

def prepare_parse(src):

    s = create_test_string(src)
    text = get_string_addr(s)
    end = text + get_string_size(s)

    return text, end

def parse_test(src):

    return parse(*prepare_parse(src))

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

    name = get_symbol_name(quote_symbol.value&~7)
    assert is_string(name)
    assert get_string_length(name) == 5
    assert string_equal(get_symbol_name(quote_symbol.value&~7), create_test_string('quote'))

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

    assert parse_test('') == error_incomplete_input.value

def test_parse_symbol():
    init_test()

    src = 'a'
    assert parse_test(src) == make_symbol(create_test_string(src))

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_small_integer(radix, fmt):

    init_test()

    for i in range(-20, 21):
        src = f'{radix}{{i:{fmt}}}'.format(i=i)
        print(src)
        assert parse_test(src) >> tag_size_bits.value == i

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_rational(radix, fmt):

    init_test()

    for n in range(-20, 21):
        for d in range(1, 20):
            src = f'{radix}{{n:{fmt}}}/{{d:{fmt}}}'.format(n=n, d=d)

            value = parse_test(src)
            if n % d == 0:
                assert not is_rational(value)
                assert value >> tag_size_bits.value == n / d
            else:
                assert is_rational(value)

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_full_complex(radix, fmt):

    init_test()

    for re in range(-20, 21):
        for im in range(-20, 21):
            src = f'{radix}{{re:{fmt}}}{{im:+{fmt}}}i'.format(re=re, im=im)
            value = parse_test(src)
            if im != 0:
                assert is_complex(value)
                assert real_part(value) >> tag_size_bits.value == re
                assert imag_part(value) >> tag_size_bits.value == im
            else:
                assert value >> tag_size_bits.value == re


@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_polar(radix, fmt):

    init_test()

    for m in range(0, 5):
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
        src = f'{radix}{{re:{fmt}}}+i'.format(re=re)
        value = parse_test(src)
        assert is_complex(value)
        assert real_part(value) >> tag_size_bits.value == re
        assert imag_part(value) >> tag_size_bits.value == 1

        src = f'{radix}{{re:{fmt}}}-i'.format(re=re)
        value = parse_test(src)
        assert is_complex(value)
        assert real_part(value) >> tag_size_bits.value == re
        assert imag_part(value) >> tag_size_bits.value == -1

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_im_only(radix, fmt):

    init_test()

    for im in range(-20, 21):
        src = f'{radix}{{im:+{fmt}}}i'.format(im=im)
        print(src)
        value = parse_test(src)
        if im != 0:
            assert is_complex(value)
            assert real_part(value) == 0
            assert imag_part(value) >> tag_size_bits.value == im
        else:
            assert value == 0

@pytest.mark.parametrize('radix,fmt', [('#b', 'b'), ('#o', 'o'), ('', 'd'), ('#d', 'd'), ('#x', 'x')])
def test_parse_complex_infnan_im(radix, fmt):

    init_test()

    for re in range(-20, 21):
        for sign in '+-':
            for im_val in ['inf', 'nan']:
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

@pytest.mark.slow
def test_parse_exact_decimal():

    init_test()

    for src, value in zip(decimal_test_cases, exact_decimal_test_values):
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

@pytest.mark.slow
def test_parse_decimal():

    init_test()

    for src in decimal_test_cases:
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

    result = parse_test(src)

    try:
        assert to_int(result) == value

    except:
        print(src)
        print(py_src)
        print(format_addr(to_int(result)))
        print(hex(value))
        print(value)

        raise

def test_octal_integer():

    init_test()

    for i in range(1, 80):
        for d in range(0, 8):
            check_octal_integer(str(d)*i)
            check_octal_integer(str(d)+'0'*(i-1))

def test_octal_number_forms():

    init_test()

    result = parse_test('#i#o26/7')
    assert get_boxed_f64(result) == 0o26/7

def check_hexidecimal_integer(src_base):

    src = f'#x{src_base}'
    py_src = f'0x{src_base}'
    value = eval(py_src)

    result = parse_test(src)

    try:
        assert to_int(result) == value

    except:
        print(src)
        print(py_src)
        print(format_addr(result))
        print(format_addr(to_int(result)))
        print(value)

        raise

def test_hexidecimal_integer():

    init_test()

    for i in range(1, 80):
        for d in range(16):
            check_hexidecimal_integer(('%x' % d)*i)
            check_hexidecimal_integer(('%x' % d)+'0'*(i-1))
            check_hexidecimal_integer(('%X' % d)*i)
            check_hexidecimal_integer(('%X' % d)+'0'*(i-1))

def check_binary_integer(src_base):

    src = f'#b{src_base}'
    py_src = f'0b{src_base}'
    value = eval(py_src)

    result = parse_test(src)

    try:
        assert to_int(result) == value

    except:
        print(src)
        print(py_src)
        print(format_addr(result))
        print(format_addr(to_int(result)))
        print(value)

        raise

def test_binary_integer():

    init_test()

    for i in range(1, 200):
        for d in ('0', '1'):
            check_binary_integer(d*i)
            check_binary_integer(d+'0'*(i-1))

def test_empty_bytevector():

    init_test()

    empty_bytevectors = (
        '#u8()',
        '  #u8(;a comment\n)',
    )

    for src in empty_bytevectors:
        value = parse_test(src)
        assert is_bytevector(value)
        assert get_bytevector_size(value) == 0

def test_simple_bytevector():

    init_test()

    for b in range(0, 255):
        src = f'#u8({b})'
        value = parse_test(src)

        assert is_bytevector(value)
        assert get_bytevector_size(value) == 1
        assert get_bytevector_i8_u(value, 0) == b

def test_bytevector_number_radixes():

    init_test()

    src = '#u8(#b1111 #o17 15 #d15 #xf)'
    value = parse_test(src)

    assert is_bytevector(value)
    assert get_bytevector_size(value) == 5
    for i in range(0, 5):
        assert get_bytevector_i8_u(value, i) == 15

def test_bytevector_number_normalization():

    init_test()

    src = '''
    #u8(
      #x0000000000000000f ; 17 digits will parse into a (large) integer
      32768/256 ; = 128, check rationals
      #e1.0e1 ; = 10, check exact decimals
      25+0i ; = 25, check complex
    )
    '''
    value = parse_test(src)

    assert is_bytevector(value)
    assert get_bytevector_size(value) == 4
    assert get_bytevector_i8_u(value, 0) == 15
    assert get_bytevector_i8_u(value, 1) == 128
    assert get_bytevector_i8_u(value, 2) == 10
    assert get_bytevector_i8_u(value, 3) == 25

def test_empty_string():
    init_test()
    src = '""'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 0
    assert get_string_size(value) == 0

def test_one_char_string():
    init_test()
    src = '"a"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 1
    assert get_string_char(get_string_addr(value)) == ord('a')

def test_string_mnemonic_escapes():

    init_test()

    for m, c in ('a\a', 'b\b', 'n\n', 'r\r', 't\t'):
        src = f'"\\{m}"'
        value = parse_test(src)
        assert is_string(value)
        assert get_string_length(value) == 1
        assert get_string_size(value) == 1
        assert get_string_char(get_string_addr(value)) == ord(c)

def test_string_escaped_backslash():

    init_test()

    src = r'"\\"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 1
    assert get_string_char(get_string_addr(value)) == ord('\\')

def test_string_escaped_double_quote():

    init_test()

    src = r'"\""'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 1
    assert get_string_char(get_string_addr(value)) == ord('"')

def test_string_escaped_line_ending():

    init_test()

    src = '"a\\ \n b"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 2
    assert get_string_size(value) == 2
    addr = get_string_addr(value)
    assert get_string_char(addr) == ord('a')
    assert get_string_char(addr+1) == ord('b')

def test_string_2byte_character():
    init_test()
    src = '"λ"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 2
    assert struct.pack('<H', get_string_char(get_string_addr(value))).decode() == 'λ'

def test_string_3byte_character():
    init_test()
    src = '"ᴁ"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 3
    assert struct.pack('<I', get_string_char(get_string_addr(value)))[:3].decode() == 'ᴁ'

def test_string_4byte_character():
    init_test()
    src = '"𝅘𝅥𝅮"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 4
    assert struct.pack('<I', get_string_char(get_string_addr(value))+(1<<32)).decode() == '𝅘𝅥𝅮'

def test_simple_strings():

    init_test()

    s = ''
    for i in range(1, 300):
        c = chr(i%96+32)
        if c in '"\\':
            s += '\\'

        s += c
        src = f'"{s}"'
        value = parse_test(src)
        assert is_string(value)
        assert get_string_length(value) == i
        assert get_string_size(value) == i

def test_long_strings():

    init_test()

    base = 'λᴁ 𝅘𝅥𝅮'

    for i in range(9):
        base = base + base + base
        src = f'"{base}"'
        value = parse_test(src)
        assert is_string(value)
        assert get_string_length(value) == len(base)
        assert get_string_size(value) == len(base.encode())

def test_string_hex_escape():

    init_test()
    src = '"\\x20;"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 1
    assert get_string_char(get_string_addr(value)) == ord(' ')

    src = '"λ"'
    value = parse_test(src)
    print(format_addr(get_string_char(get_string_addr(value))))

    src = '"\\x3bb;"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 2
    print(format_addr(get_string_char(get_string_addr(value))))
    assert struct.pack('<H', get_string_char(get_string_addr(value))).decode() == 'λ'

    src = '"\\x1d11e;"'
    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 1
    assert get_string_size(value) == 4
    assert struct.pack('<I', get_string_char(get_string_addr(value))+(1<<32)).decode() == '𝄞'

def test_string_integration():

    init_test()

    # chars
    #   | length
    #   |    | description
    # --------------------------------------------------------------------------
    # 4 |  4 | four single-byte characters
    # 1 |  4 | a four-byte character expressed as a hex inline escape
    # 1 |  2 | a two-byte character
    # 0 |  0 | an escaped line ending, including surrounding whitespace
    # 3 |  3 | three more single-byte characters
    # --------------------------------------------------------------------------
    # 9 | 13 | totals

    src = '"0123\\x1d11e;λ\\ \n\t\t 456"'

    value = parse_test(src)
    assert is_string(value)
    assert get_string_length(value) == 9
    assert get_string_size(value) == 13
    addr = get_string_addr(value)

    assert get_string_char(addr) == ord('0')
    assert get_string_char(addr+1) == ord('1')
    assert get_string_char(addr+2) == ord('2')
    assert get_string_char(addr+3) == ord('3')
    assert struct.pack('<I', get_string_char(addr+4)+(1<<32)).decode() == '𝄞'
    assert struct.pack('<H', get_string_char(addr+8)).decode() == 'λ'
    assert get_string_char(addr+10) == ord('4')
    assert get_string_char(addr+11) == ord('5')
    assert get_string_char(addr+12) == ord('6')

def test_simple_char():

    init_test()

    for i in range(32, 128):
        src = f'#\\{chr(i)}'
        value = parse_test(src)
        assert is_char(value)
        assert get_char_code_point(value) == i

def test_named_char():

    init_test()

    for name, c in (('alarm',     '\u0007'),
                    ('backspace', '\u0008'),
                    ('delete',    '\u007f'),
                    ('escape',    '\u001b'),
                    ('newline',   '\u000a'),
                    ('null',      '\u0000'),
                    ('return',    '\u000d'),
                    ('space',     ' '),
                    ('tab',       '\u0009')):

        print(name, c)
        src = f'#\\{name}'
        value = parse_test(src)
        assert is_char(value)
        assert get_char_code_point(value) == ord(c)

def test_character_hex_escape():

    init_test()

    # src = '#\\x20 '
    # value = parse_test(src)
    # assert is_char(value)
    # assert get_char_code_point(value) == ord(' ')

    src = '#\\x3bb'
    value = parse_test(src)
    assert is_char(value)
    assert get_char_code_point(value) == ord('λ')

    src = '#\\x1d11e'
    value = parse_test(src)
    assert is_char(value)
    assert get_char_code_point(value) == ord('𝄞')

def test_booleans():

    init_test()

    src = '#t'
    value = parse_test(src)
    assert value == TRUE

    src = '#true'
    value = parse_test(src)
    assert value == TRUE

    src = '#f'
    value = parse_test(src)
    assert value == FALSE

    src = '#false'
    value = parse_test(src)
    assert value == FALSE

def test_identifiers():

    init_test()

    src = 'foo'
    assert parse_test(src) == make_symbol(create_test_string(src))

    src = 'foo-1z3'
    assert parse_test(src) == make_symbol(create_test_string(src))

    special_initials = '!$%&*/:<=>?^_~'

    for c in special_initials:
        src = c + 'foo'
        assert parse_test(src) == make_symbol(create_test_string(src))

    vertical_line_quoted_identifier_cases = (
        ('||', ''),
        (r'|\||', '|'),
        (r'|\a\b\n\r\t|', '\a\b\n\r\t'),
        (r'|\xbeef;|', '\ubeef'),
        ('|foo \n bar|', 'foo \n bar'),
        ('|dos foo \r\n bar|', 'dos foo \r\n bar'),
    )

    for src, result in vertical_line_quoted_identifier_cases:
        assert parse_test(src) == make_symbol(create_test_string(result))

    peculiar_identifiers = (
        '+',
        '-',
        '-?!A',
        '...',
    )

    for src in peculiar_identifiers:
        assert parse_test(src) == make_symbol(create_test_string(src))

def test_vectors():

    init_test()

    src = '#()'
    value = parse_test(src)
    assert is_vector(value)
    assert get_vector_length(value) == 0

    src = '#(#\\space "foo" bar 3.14 42)'
    value = parse_test(src)
    assert is_vector(value)
    assert get_vector_length(value) == 5
    assert get_char_code_point(get_vector_element(value, 0)) == ord(' ')
    assert is_string(get_vector_element(value, 1))
    assert string_equal(get_vector_element(value, 1), create_test_string('foo'))
    assert get_vector_element(value, 2) == make_symbol(create_test_string('bar'))
    assert is_boxed_f64(get_vector_element(value, 3))
    assert get_boxed_f64(get_vector_element(value, 3)) == 3.14
    assert get_vector_element(value, 4) >> 3 == 42

def test_quasiquote():

    init_test()

    src = "`foo"
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 2
    e1 = get_car(value)
    e2 = get_cdar(value)
    print(format_addr(e1), format_addr(parse_mod.p1.value))
    assert is_symbol(e1)
    assert e1 == quasiquote_symbol.value
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('foo'))

def test_quote():

    init_test()

    src = "'foo"
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 2
    e1 = get_car(value)
    e2 = get_cdar(value)
    assert is_symbol(e1)
    assert e1 == quote_symbol.value
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('foo'))

def test_unquote():

    init_test()

    src = ",foo"
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 2
    e1 = get_car(value)
    e2 = get_cdar(value)
    assert is_symbol(e1)
    assert e1 == unquote_symbol.value
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('foo'))

def test_unquote_splicing():

    init_test()

    src = ",@foo"
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 2
    e1 = get_car(value)
    e2 = get_cdar(value)
    assert is_symbol(e1)
    assert e1 == unquote_splicing_symbol.value
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('foo'))

def test_dot():

    init_test()

    src = '(foo . bar)'
    value = parse_test(src)
    assert is_pair(value)
    e1 = get_car(value)
    e2 = get_cdr(value)
    assert is_symbol(e1)
    assert e1 == make_symbol(create_test_string('foo'))
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('bar'))

def test_directives():

    init_test()

    src = '#!fold-case(FOO . #!no-fold-case BAR)'

    value = parse_test(src)
    assert is_pair(value)
    e1 = get_car(value)
    e2 = get_cdr(value)
    assert is_symbol(e1)
    assert e1 == make_symbol(create_test_string('foo'))
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('BAR'))

    src = '#!fold-case #T'
    value = parse_test(src)
    assert value == TRUE

    src = '#!fold-case #False'
    value = parse_test(src)
    assert value == FALSE

    src = '#!fold-case #\\sPaCe'
    value = parse_test(src)
    assert get_char_code_point(value) == ord(' ')

def test_ordinary_comment():

    init_test()

    src = '(foo ; . bar \n . baz)'
    value = parse_test(src)
    assert is_pair(value)
    e1 = get_car(value)
    e2 = get_cdr(value)
    assert is_symbol(e1)
    assert e1 == make_symbol(create_test_string('foo'))
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('baz'))

def test_nested_comments():

    init_test()

    src = '''#|
       start of a nested comment #| eggs go here |#
       3.14
    |#
    42
    '''
    value = parse_test(src)
    assert is_small_integer(value)
    assert to_int(value) == 42

def test_datum_comments():

    init_test()

    src = '#u8(#;42 3)'
    value = parse_test(src)
    assert is_bytevector(value)
    assert get_bytevector_size(value) == 1
    assert get_bytevector_i8_u(value, 0) == 3

    src = '#u8(#;3.14 3)'
    value = parse_test(src)
    assert is_bytevector(value)
    assert get_bytevector_size(value) == 1
    assert get_bytevector_i8_u(value, 0) == 3

    src = '#u8(#;#;3.14 #\\space 3)'
    value = parse_test(src)
    assert is_bytevector(value)
    assert get_bytevector_size(value) == 1
    assert get_bytevector_i8_u(value, 0) == 3

def test_simple_lists():

    init_test()

    src = '()'
    value = parse_test(src)
    assert value == NULL

    src = '(a)'
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 1
    e1 = get_car(value)
    assert is_symbol(e1)
    assert e1 == make_symbol(create_test_string('a'))

    src = '(#(1) foo)'
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 2
    e1 = get_car(value)
    assert is_vector(e1)
    assert get_vector_length(e1) == 1
    e1_1 = get_vector_element(e1, 0)
    assert is_small_integer(e1_1)
    assert to_int(e1_1) == 1
    e2 = get_cdar(value)
    assert is_symbol(e2)
    assert e2 == make_symbol(create_test_string('foo'))

    src = '(a . ())'
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 1
    e1 = get_car(value)
    assert is_symbol(e1)
    assert e1 == make_symbol(create_test_string('a'))

def test_nested_lists():

    init_test()

    src = '(a (b c) (d (e (f g))))'
    value = parse_test(src)
    assert is_pair(value)
    assert get_list_length(value) == 3
    e1 = get_car(value)
    assert is_symbol(e1)
    assert e1 == make_symbol(create_test_string('a'))
    e2 = get_cdar(value)
    assert is_pair(e2)
    assert get_list_length(e2) == 2
    e2_1 = get_car(e2)
    assert is_symbol(e2_1)
    assert e2_1 == make_symbol(create_test_string('b'))
    e2_2 = get_cdar(e2)
    assert is_symbol(e2_2)
    assert e2_2 == make_symbol(create_test_string('c'))
    e3 = get_cddar(value)
    assert is_pair(e3)
    assert get_list_length(e3) == 2
    e3_1 = get_car(e3)
    assert is_symbol(e3_1)
    assert e3_1 == make_symbol(create_test_string('d'))
    e3_2 = get_cdar(e3)
    assert is_pair(e3_2)
    assert get_list_length(e3_2) == 2
    e3_2_1 = get_car(e3_2)
    assert is_symbol(e3_2_1)
    assert e3_2_1 == make_symbol(create_test_string('e'))
    e3_2_2 = get_cdar(e3_2)
    assert is_pair(e3_2_2)
    assert get_list_length(e3_2_2) == 2
    e3_2_2_1 = get_car(e3_2_2)
    assert is_symbol(e3_2_2_1)
    assert e3_2_2_1 == make_symbol(create_test_string('f'))
    e3_2_2_2 = get_cdar(e3_2_2)
    assert is_symbol(e3_2_2_2)
    assert e3_2_2_2 == make_symbol(create_test_string('g'))

def test_error_unmatched_close_paren():

    init_test()

    src = ')'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unmatched_close_parenthesis.value
    assert get_parse_location() == text

    init_parser()

    src = ' )'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unmatched_close_parenthesis.value
    assert get_parse_location() == text+1

    init_parser()

def test_error_datum_expected():

    init_test()

    init_parser()
    src = '(#;)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_datum_expected.value
    assert get_parse_location() == text+3

    # todo hang on next parse here -- error in unwind stack
    # init_parser()

def test_error_close_paren_expected():

    init_test()

    init_parser()
    src = '(1 . 2 . 3)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_close_parenthesis_expected.value
    assert get_parse_location() == text+7

    init_parser()

    src = '(1 . 2 3)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_close_parenthesis_expected.value
    assert get_parse_location() == text+7

    init_parser()

def test_error_illegal_use_of_dot():

    init_test()

    src = '#(1 . 2)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_use_of_dot.value
    assert get_parse_location() == text+4

    init_parser()

    src = '#u8(1 . 2)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_use_of_dot.value
    assert get_parse_location() == text+6

    init_parser()

    src = '#u8(1 2 . ())'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_use_of_dot.value
    assert get_parse_location() == text+8

    init_parser()

def test_error_invalid_bytevector_negative():

    init_test()

    src = '#u8(-1)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_bytevector_element.value
    assert get_parse_location() == text+4

    init_parser()

def test_error_invalid_bytevector_overflow():
    init_test()

    src = '#u8(256)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_bytevector_element.value
    assert get_parse_location() == text+4

    init_parser()

def test_error_invalid_bytevector_rational():
    init_test()

    src = '#u8(1/2)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_bytevector_element.value
    assert get_parse_location() == text+4

    init_parser()

def test_error_invalid_bytevector_float():
    init_test()

    src = '#u8(#i#b1)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_bytevector_element.value
    assert get_parse_location() == text+4

    init_parser()

def test_error_invalid_bytevector_complex():
    init_test()

    src = '#u8(1+2i)'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_bytevector_element.value
    assert get_parse_location() == text+4

    init_parser()

def test_error_invalid_bytevector_non_numeric():
    init_test()

    src = '#u8(#u8(0))'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_illegal_bytevector_element.value
    assert get_parse_location() == text+4

    init_parser()

def test_error_delimiter_must_follow_directive():

    init_test()

    src = '#!fold-case42'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_delimiter_must_follow_directive.value
    assert get_parse_location() == text

    init_parser()

def test_error_unrecognized_token():

    init_test()

    src = '1e-21a'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unrecognized_token.value
    assert get_parse_location() == text

    init_parser()

    src = '#truest'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unrecognized_token.value
    assert get_parse_location() == text

    init_parser()

    src = '#\\spaces'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unrecognized_token.value
    assert get_parse_location() == text

    init_parser()

    src = '.\\'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unrecognized_token.value
    assert get_parse_location() == text

    init_parser()

    src = '"hello'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_unrecognized_token.value
    assert get_parse_location() == text

    init_parser()

def test_error_inline_hex_overflow():

    init_test()

    src = '"\\xdeadbeef0;"'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_inline_hex_overflow.value
    assert get_parse_location() == text+1

    init_parser()

def test_error_invalid_code_point():

    init_test()

    src = '"\\xdeadbeef;"'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_invalid_code_point.value
    assert get_parse_location() == text+1

    init_parser()

def test_error_incomplete_input():

    init_test()

    src = '(foo ...'
    text, end = prepare_parse(src)
    value = parse(text, end)
    assert value == error_incomplete_input.value
    assert get_parse_location() == text+8

    init_parser()

#todo: memory leaks
