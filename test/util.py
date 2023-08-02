import math
import random

from modules.debug.strings import *
from modules.debug import numbers, strings

NULL = -1

def u32(x):
    if x < 0:
        return x + (1<<32)

def format_addr(addr):
    if addr == NULL:
        return 'NULL'

    elif addr < 0:
        return hex((abs(addr) ^ 0xffffffff) + 1)

    else:
        return hex(addr)

# Adapted from https://stackoverflow.com/a/15330851
# Much lighter than adding numpy or scikit as a dependency.

def sample_poisson(expected_value):

    n = 0
    limit = math.exp(-expected_value)

    x = random.random()
    while x > limit:
        n += 1
        x *= random.random()

    return n

def sample_power_law(x_min, alpha):
    # x_min = 5
    # alpha = 2.5
    return x_min * (1 - random.random()) ** (-1 / (alpha - 1))

def create_test_string(text, size=None):
    data = text.encode()
    s = alloc_string(len(text), size or len(data))
    addr = get_string_addr(s)
    for i, b in enumerate(data):
        set_string_bytes(addr+i, b, 1)
    return s

def to_int(x):

    if numbers.is_small_integer(x):

        if x < 0:
            x += 1<<32

        return x >> 3

    elif numbers.is_boxed_i64(x):

        v = numbers.get_boxed_i64(x)

        return v

    elif numbers.is_rational(x) or numbers.is_complex(x) or numbers.is_boxed_f64(x):
        assert False

    else:
        return integer_to_int(x)

def integer_to_int(x):
    v = 0

    for i in range(numbers.get_integer_size(x)):

        digit = numbers.get_integer_digit_i64(x, i)

        if digit < 0:
            digit += 1<<64

        v += digit << (64*i)

    return v

def to_str(start, end):
    data = bytearray()

    for addr in range(start, end):
        data.append(strings.get_string_bytes(addr, 1))

    return data.decode()
