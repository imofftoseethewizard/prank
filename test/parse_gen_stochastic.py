import random

from collections import namedtuple

from util import create_test_string, format_addr, to_int, to_str
from validate import blocks, free_blocks, prepare_validation, validate


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
from modules.debug import chars, numbers, strings, symbols

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

def prepare_parse(src):

    encoded_size = len(src.encode())

    # strings less than 1024 bytes long may be relocated during deallocation.
    # since parsing uses string addrs for efficiency, it is vital to ensure
    # that the buffer does not move.
    s = create_test_string(src, size=max(1024, encoded_size))

    text = get_string_addr(s)
    end = text + encoded_size

    return text, end

NULL = NULL.value
TRUE = TRUE.value
FALSE = FALSE.value

Boolean      = namedtuple('Boolean',       ('value', 'text'))
ByteVector   = namedtuple('ByteVector',    ('elements', 'text'))
Character    = namedtuple('Character',     ('value', 'text'))
Complex      = namedtuple('Complex',       ('re', 'im', 'text'))
DatumComment = namedtuple('DatumComment',  ('text',))
F64          = namedtuple('F64',           ('value', 'text'))
I64          = namedtuple('I64',           ('value', 'text'))
Identifier   = namedtuple('Identifier',    ('value', 'text'))
Integer      = namedtuple('Integer',       ('value', 'text'))
List         = namedtuple('List',          ('elements', 'text'))
Rational     = namedtuple('Rational',      ('n', 'd', 'text'))
SmallInteger = namedtuple('SmallInteger',  ('value', 'text'))
String       = namedtuple('String',        ('value', 'text'))
Vector       = namedtuple('Vector',        ('elements', 'text'))

def random_boolean():
    return random.choice((True, False))

def join_whitespace(xs):
    text = ''

    for x in xs[:-1]:
        text += x.text
        text += generate_whitespace()

    if xs:
        text += xs[-1].text

    return text

def generate_radix():
    return random.choice((2, 8, 10, 16))

def generate_exactness():
    return random.choice(('', 'e', 'i'))

def generate_whitespace():
    return random.choice(' \t\n')

def generate_boolean():
    value = random_boolean()
    is_abbrev = random_boolean()
    if value:
        if is_abbrev:
            return Boolean(True, '#t')
        else:
            return Boolean(True, '#true')
    else:
        if is_abbrev:
            return Boolean(False, '#f')
        else:
            return Boolean(False, '#false')

    assert False

def generate_bytevector():
    elements = [generate_byte() for i in range(random.randrange(7))]
    return ByteVector(elements, '#u8(' + join_whitespace(elements) + ')')

def generate_byte():
    radix = generate_radix()
    exactness = random.choice(('', 'e'))
    v = random.randrange(256)
    return SmallInteger(v, generate_prefix(radix, exactness) + format_int(v, radix))

def generate_character():
    choice = random.randrange(3)

    if choice == 0:
        return generate_literal_character()

    if choice == 1:
        return generate_named_character()

    if choice == 2:
        return generate_scalar_hex_character()

    assert False

def generate_literal_character():

    choice = random.randrange(4)

    if choice == 0:
        return generate_ascii_character()

    if choice == 1:
        return generate_2_byte_character()

    if choice == 2:
        return generate_3_byte_character()

    if choice == 3:
        return generate_4_byte_character()

    assert False

def generate_ascii_character():

    code_point = random.randrange(32, 128)
    return Character(code_point, f'#\\{chr(code_point)}')

def generate_2_byte_character():
    return Character(ord('λ'), '#\\λ')

def generate_3_byte_character():
    return Character(ord('ᴁ'), '#\\ᴁ')

def generate_4_byte_character():
    return Character(ord('𝅘𝅥𝅮'), '#\\𝅘𝅥𝅮')

def generate_named_character():

    return Character(*random.choice((
        (0x07, '#\\alarm'),
        (0x08, '#\\backspace'),
        (0x7f, '#\\delete'),
        (0x1b, '#\\escape'),
        (0x0a, '#\\newline'),
        (0x00, '#\\null'),
        (0x0d, '#\\return'),
        (0x20, '#\\space'),
        (0x09, '#\\tab')
    )))

def generate_scalar_hex_character():

    code_point = random.randrange(0x110000)
    return Character(code_point, f'#\\x{code_point:x}')

def generate_complex():

    choice = random.randrange(5)

    if choice == 0:
        return generate_polar_complex()

    if choice == 1:
        return generate_ordinary_complex()

    if choice == 2:
        return generate_unit_im_complex()

    if choice == 3:
        return generate_im_only_complex()

    if choice == 4:
        return generate_unit_im_only_complex()

    assert False

def generate_polar_complex():

    radix = generate_radix()
    exactness = generate_exactness()

    mag = generate_real(radix, exactness)
    arg = generate_real(radix, exactness)

    return Complex(mag, arg, generate_prefix(radix, exactness) + mag.text + '@' + arg.text)

def generate_ordinary_complex():

    radix = generate_radix()
    exactness = generate_exactness()

    re = generate_real(radix, exactness)
    im = generate_real(radix, exactness)

    if im.text.startswith('+') or im.text.startswith('-'):
        im_sign = ''
    else:
        im_sign = '+'

    return Complex(re, im, generate_prefix(radix, exactness) + re.text + im_sign + im.text + 'i')

def generate_unit_im_complex():

    radix = generate_radix()
    exactness = generate_exactness()

    re = generate_real(radix, exactness)

    if random_boolean():
        im = SmallInteger(1, '+')
    else:
        im = SmallInteger(-1, '-')

    return Complex(re, 1, generate_prefix(radix, exactness) + re.text + im.text + 'i')

def generate_im_only_complex():

    radix = generate_radix()
    exactness = generate_exactness()

    re = SmallInteger(0, '')
    im = generate_real(radix, exactness)

    if im.text.startswith('+') or im.text.startswith('-'):
        im_sign = ''
    else:
        im_sign = '+'

    return Complex(re, im, generate_prefix(radix, exactness) + im_sign + im.text + 'i')

def generate_unit_im_only_complex():

    radix = generate_radix()
    exactness = generate_exactness()

    re = SmallInteger(0, '')

    if random_boolean():
        im = SmallInteger(1, '+')
    else:
        im = SmallInteger(-1, '-')

    return Complex(re, im, generate_prefix(radix, exactness) + im.text + 'i')

def generate_prefix(radix, exactness):

    if radix == 10 and random_boolean():
        return format_exactness(exactness)

    elif random_boolean():
        return format_exactness(exactness) + format_radix(radix)

    else:
        return format_radix(radix) + format_exactness(exactness)

    assert False

def generate_real(radix, exactness):

    if exactness == 'i':
        return generate_inexact_real(radix)

    if exactness == 'e' or radix != 10 and exactness == '':
        return generate_exact_real(radix)

    # => radix == 10 and exactness == ''

    if random_boolean():
        return generate_decimal()

    else:
        return generate_exact_real(10)

    assert False

def generate_exact_real(radix, allow_rationals=True):

    choice = random.randrange(22 if allow_rationals else 21)

    if choice < 16:
        return generate_small_integer(radix)

    if choice < 20:
        return generate_i64(radix)

    if choice == 20:
        return generate_integer(radix)

    if choice == 21:
        return generate_rational(radix)

    assert False

def generate_inexact_real(radix):

    if random_boolean():
        return generate_infnan()

    else:
        r = generate_exact_real(radix)

        if type(r) == Rational:
            v = r.n / r.d
        else:
            v = float(r.value)

        return F64(v, r.text)

    assert False

def generate_small_integer(radix):

    sign = random.choice(('', '+', '-'))
    v = random.randrange(1<<28)
    return SmallInteger(v * (-1 if sign == '-' else 1), sign + format_int(v, radix))

def generate_i64(radix):

    sign = random.choice(('', '+', '-'))
    v = random.randrange(1<<28, 1<<63)
    return I64(v * (-1 if sign == '-' else 1), sign + format_int(v, radix))

def generate_integer(radix):

    sign = random.choice(('', '+', '-'))
    v = random.randrange(1<<63, 1<<256)
    return Integer(v * (-1 if sign == '-' else 1), sign + format_int(v, radix))

def generate_decimal():

    choice = random.randrange(3)

    if choice == 0:
        text = generate_decimal_digits()

    elif choice == 1:
        text = '.' + generate_decimal_digits()

    else:
        text = generate_decimal_digits() + '.' + generate_decimal_digits()

    text += generate_decimal_suffix()

    return F64(float(text), text)

def generate_decimal_digits():
    return ''.join(random.choices('0123456789', k=random.randrange(1, 16)))

def generate_decimal_suffix():

    if random_boolean():
        return ''

    else:
        return 'e' + random.choice('+-') + str(random.randrange(1, 340))

    assert False

def generate_infnan():

    choice = random.randrange(4)

    if choice == 0:
        return F64(float('inf'), '+inf.0')

    if choice == 1:
        return F64(float('-inf'), '-inf.0')

    if choice == 2:
        return F64(float('nan'), '+nan.0')

    if choice == 3:
        return F64(float('nan'), '-nan.0')

    assert False

def generate_number():

    choice = random.randrange(8)

    if random_boolean():
        radix = generate_radix()
        exactness = generate_exactness()
        r = generate_real(radix, exactness)
        return type(r)(*r[:-1], generate_prefix(radix, exactness) + r.text)

    else:
        return generate_complex()

    assert False

def generate_rational(radix):

    n = generate_exact_real(radix, allow_rationals=False)
    d = generate_exact_real(radix, allow_rationals=False)

    n_val = abs(n.value)
    d_val = abs(d.value)

    n_text = n.text[1:] if n.text[0] in '+-' else n.text
    d_text = d.text[1:] if d.text[0] in '+-' else d.text

    if n.value * d.value < 1:
        n_val *= -1
        n_text = '-' + n_text

    return Rational(n_val, d_val, n_text + '/' + d_text)

def generate_datum(allow_datum_comment=False):

    choice = random.randrange(9 if allow_datum_comment else 8)

    if choice == 0:
        return generate_boolean()

    if choice == 1:
        return generate_bytevector()

    if choice == 2:
        return generate_character()

    if choice == 3:
        return generate_identifier()

    if choice == 4:
        return generate_number()

    if choice == 5:
        return generate_string()

    if choice == 6:
        return generate_list()

    if choice == 7:
        return generate_vector()

    if choice == 8:
        return generate_datum_comment()

    assert False

def generate_datum_comment():
    d = generate_datum(allow_datum_comment=False)
    return DatumComment('#; ' + d.text)

def generate_list():
    elements = [generate_datum() for i in range(random.randrange(7))]
    return List(elements, '(' + join_whitespace(elements) + ')')

def generate_vector():
    elements = [generate_datum() for i in range(random.randrange(7))]
    return Vector(elements, '#(' + join_whitespace(elements) + ')')

def format_exactness(exactness):
    return '#' + exactness if exactness else ''

def format_int(v, radix):

    if radix == 2:
        return f'{v:b}'

    if radix == 8:
        return f'{v:o}'

    if radix == 10:
        return f'{v:d}'

    if radix == 16:
        return f'{v:x}'

    assert False

radix_chars = {
    2: 'b',
    8: 'o',
    10: 'd',
    16: 'x',
}

def format_radix(radix):
    return '#' + radix_chars[radix]

def generate_uint(N=128):
    return int(random.random()*(2**random.randrange(N)))

words = open('/usr/share/dict/words').read().split('\n')

def generate_identifier():
    w = random.choice(words)
    if set("'íûÅçåñêâèôüäéöáó") & set(w): # todo unicode identifers
        return Identifier(w, '|' + w + '|')
    else:
        return Identifier(w, w)

def generate_string():
    ws = random.choices(words, k=random.randrange(1, 10))
    s = ' '.join(ws)
    return String(s, '"' + s + '"')

def stochastic_test(N, seed=0, check_valid=True):
    random.seed(seed)
    init_test()
    for i in range(N):
      d = generate_datum()
      try:
        init_parser()
        start, end = prepare_parse(d.text)
        v = parse(start, end)
        assert v & 0xffff != 0x0107
        check_result(d, v)
        dealloc_value(v)
        if check_valid:
            validate()
      except:
        print()
        print(i)
        print('------------------------------------------------------')
        print(d.text)
        print('------------------------------------------------------')
        print(to_str(start, end))
        print('------------------------------------------------------')
        print('')
        print(get_parse_location() - start)
        print(format_addr(v))
        raise

indent = ''

def print_value(v):
    if is_pair(v):
        print_list(v)

    elif is_vector(v):
        print_vector(v)

    elif is_bytevector(v):
        print_bytevector(v)

    elif numbers.is_small_integer(v):
        print_number(v)

    elif numbers.is_boxed_i64(v):
        print_number(v)

    elif numbers.is_rational(v):
        print('rational')
        # print_number(v)

    elif numbers.is_complex(v):
        print('complex')
        # print_number(v)

    elif numbers.is_boxed_f64(v):
        print('f64')
        # print_number(v)

    elif is_string(v):
        print_string(v)

    elif is_symbol(v):
        print_symbol(v)

    elif is_char(v):
        print_character(v)

    elif v == NULL:
        print(indent + '()')

    elif v == FALSE:
        print(indent + '#false')

    elif v == TRUE:
        print(indent + '#true')

    else:
        print('other -- probably integer')
        #assert False

def print_list(v):
    global indent
    print(indent + '(')
    indent += ' '
    head = v
    while head != NULL:
        print_value(get_car(head))
        head = get_cdr(head)
    indent = indent[:-1]
    print(indent + ')')

def print_vector(v):
    global indent
    print(indent + '#(')
    indent += '  '
    for i in range(vectors.get_vector_length(v)):
        print_value(vectors.get_vector_element(v, i))
    indent = indent[:-2]
    print(indent + ')')

def print_bytevector(v):
    global indent
    print(indent + '#u8(')
    indent += '    '
    for i in range(bytevectors.get_bytevector_size(v)):
        print(indent + hex(bytevectors.get_bytevector_i8_u(v, i)))
    indent = indent[:-4]
    print(indent + ')')

def print_number(v):
    print(indent + str(to_int(v)))

def print_string(v):
    addr = strings.get_string_addr()
    print(to_str(addr, addr + strings.get_string_size()))

def print_symbol(v):
    print(indent + '<a symbol>')

def print_character(v):
    print(indent + '<a character>')

def check_result(d, v):
    if is_pair(v):
        assert type(d) == List
        # NB. the code in this file only generates proper lists atm.
        head = v
        idx = 0
        while head != NULL:
            check_result(d.elements[idx], get_car(head))
            head = get_cdr(head)
            idx += 1
        assert idx == len(d.elements)

    elif is_vector(v):
        assert type(d) == Vector
        assert len(d.elements) == get_vector_length(v)
        for i, e in enumerate(d.elements):
            check_result(e, get_vector_element(v, i))

    elif is_bytevector(v):
        assert type(d) == ByteVector
        assert len(d.elements) == get_bytevector_size(v)
        for i, e in enumerate(d.elements):
            if e.value != get_bytevector_i8_u(v, i):
                print(i, e, get_bytevector_i8_u(v, i))
            assert e.value == get_bytevector_i8_u(v, i)

    # elif numbers.is_small_integer(v):
    #     print_number(v)

    # elif numbers.is_boxed_i64(v):
    #     print_number(v)

    # elif numbers.is_rational(v):
    #     print('rational')
    #     # print_number(v)

    # elif numbers.is_complex(v):
    #     print('complex')
    #     # print_number(v)

    # elif numbers.is_boxed_f64(v):
    #     print('f64')
    #     # print_number(v)

    # elif is_string(v):
    #     print_string(v)

    # elif is_symbol(v):
    #     print_symbol(v)

    # elif is_char(v):
    #     print_character(v)

    # elif v == NULL:
    #     print(indent + '()')

    # elif v == FALSE:
    #     print(indent + '#false')

    # elif v == TRUE:
    #     print(indent + '#true')

    # else:
    #     print('other -- probably integer')
    #     #assert False
