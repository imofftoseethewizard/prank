import ctypes
import math
import random

def add1(a, f):
    ah, al = a
    ah1 = ah+f
    r = f - (ah1 - ah)
    al1 = al + r
    ah2 = ah1 + al1
    al2 = al1 - (ah2 - ah1)
    return ah2, al2

def add(a, b):
    bh, bl = b
    return add1(add1(a, bl), bh)

def sub(a, b):
    bh, bl = b
    return add1(add1(a, -bl), -bh)

def mul1(a, f):
    ah, al = a
    ah1 = ah*f
    al1 = al*f
    ah2 = ah1 + al1
    al2 = al1 - (ah2 - ah1)
    return ah2, al2

def mul(a, b):
    bh, bl = b
    return add(mul1(a, bh), mul1(a, bl))

def double_to_uint64(x):
    return ctypes.c_uint64.from_buffer(ctypes.c_double(x)).value

def uint64_to_double(x):
    return ctypes.c_double.from_buffer(ctypes.c_uint64(x)).value

def format_b64(x):
    return f'{x & 0xffffffffffffffff:064b}'

def unpack_double(z):
    zb = double_to_uint64(z)
    significand = zb & 0xfffffffffffff
    exp = (zb >> 52) & 0x7ff
    sign = zb >> 63
    return sign, exp, significand

def pack_double(sign, exp, significand):
    z = (
        ((sign & 1) << 63) |
        ((exp & 0x7ff) << 52) |
        (significand & 0xfffffffffffff)
    )
    return uint64_to_double(z)

def generate_quotient_fractional_digits(x, d):
    assert x < d
    while x:
        x <<= 1
        if x > d:
            x -= d
            yield 1
        else:
            yield 0

def inv(x):
    digits = generate_quotient_fractional_digits(1, x)
    exp = 1022
    while True:
        d = next(digits)
        if d == 0:
            exp -= 1
        else:
            break
    qh = pack_double(0, exp, int(''.join(map(str, list(islice(digits, 52)))), 2))
    exp -= 53
    while True:
        d = next(digits)
        if d == 0:
            exp -= 1
        else:
            break
    ql = pack_double(0, exp, int(''.join(map(str, list(islice(digits, 52)))), 2))
    return qh, ql

def double_as_int(z):
    sign, exp, significand = unpack_double(z)

    exp = exp - 0x3ff - 52
    significand = significand | 0x10000000000000

    if exp < 0:
        significand >>= -exp
        exp = 0

    return (-1 if sign else 1) * significand * 2**exp

def int_to_df(x):
    return (float(x), float(x - double_as_int(float(x))))

def df_to_float(d):
    dh, dl = d
    return dh + 2.0*dl

def div(x, d):
    # unrolled 3 stage div algo
    xh = x[0]
    dh = d[0]
    r = sub(x, mul1(d, xh/dh))
    rh = r[0]
    e = sub(r, mul1(d, rh/dh))
    return add1((rh/dh, e[0]/dh), xh/dh)

def gt(a, b):
    ah, al = a
    bh, bl = b
    return ah > bh or ah == bh and al > bl

def lt(a, b):
    return gt(b, a)

def gte(a, b):
    return not lt(a, b)

def lte(a, b):
    return not gt(a, b)

e1 = (10.0, 0.0)
e2 = (100.0, 0.0)
e4 = (10000.0, 0.0)
e8 = (100000000.0, 0.0)
e16 = (1e+16, 0.0)
e32 = (1e+32, -5366162204393472.0)
e64 = (1e+64, -2.1320419009454396e+47)
e128 = (1e+128, -7.51744869165182e+111)
e256 = (1e+256, -3.012765990014054e+239)

# for i in range(0, 9):
#   exp = 2**i
#   print(f'en{exp} = {add1(inv(10**exp), 0.0)}')

en1 = (0.1, -5.551115123125783e-18)
en2 = (0.01, -2.0816681711721704e-19)
en4 = (0.0001, -4.79217360238593e-21)
en8 = (1e-08, -2.092256083012849e-25)
en16 = (1e-16, 2.0902213275965394e-33)
en32 = (1e-32, -5.59673099762419e-49)
en64 = (1e-64, 3.469426116645307e-81)
en128 = (1e-128, -5.401408859568104e-145)
en256 = (1e-256, 2.2671708827212433e-273)

# multiply 64-bit significands:
#    (((a >> 32) | (1 << 32)) * ((b >> 32) | (1 << 32))) & ((1<<64) - 1)
#    + carry
#  where carry = (a >> 31) & (b >> 31) & 1
#
