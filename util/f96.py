from math import log2

def generate_quotient_fractional_digits(x, d):
    assert x < d
    while x:
        x <<= 1
        if x > d:
            x -= d
            yield 1
        else:
            yield 0

def format_b64(x):
    return f'{x & 0xffffffffffffffff:064b}'

def f96_int_reciprocal(x):

    digits = generate_quotient_fractional_digits(1, x)

    exp = -1
    sig = 0

    while True:
        if next(digits):
            break
        exp -= 1

    for _ in range(64):
        sig = (sig << 1) | next(digits)

    # round up
    if next(digits):
        sig += 1

    # round to even
    # if next(digits) and sig & 1:
    #     sig += 1

    return sig, exp

def f96_convert_int(x):

    exp = int(log2(x))

    if exp > 64:
        # # truncate
        # r = 0

        # round to even
        # r = (x >> (exp - 65)) & 3
        # r = r & (r >> 1)

        # round up
        r = (x >> (exp - 65)) & 1
        sig = ((x >> (exp - 64)) & 0xffffffffffffffff) + r

    elif exp < 64:
        sig = x << (64 - exp) & 0xffffffffffffffff

    else:
        sig = x & 0xffffffffffffffff

    return sig, exp

def f96_positive_pow_10s(n):
    return [f96_convert_int(10**(2**i)) for i in range(n)]

def f96_negative_pow_10s(n):
    return [f96_int_reciprocal(10**(2**i)) for i in range(n)]

def emit_init_pow_10s():
    for n in range(-342, 309):
        if n < 0:
            sig, exp = f96_int_reciprocal(10**-n)
        else:
            sig, exp = f96_convert_int(10**n)

        print(f'   ;; 10**{n}')
        print(f'   (i64.store $sig-addr (i64.const {sig}))')
        print(f'   (%incr-n i32 $sig-addr 8)')
        print(f'   (i32.store $exp-addr (i32.const {exp}))')
        print(f'   (%incr-n i32 $exp-addr 4)')
        print()
