import math
import random

NULL = -1

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
