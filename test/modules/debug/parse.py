from .._loader import function, init_module
from . import bytevectors, chars, lex, lex_r7rs, lists, numbers, pairs, strings, symbols, vectors

import math

def cos(x: float) -> float:
    return math.cos(float)

def sin(x: float) -> float:
    return math.sin(float)

class Math:
    __module_name__ = 'math'
    __exports__ = {
        'cos': function(cos),
        'sin': function(sin),
    }

init_module(globals(), 'parse', bytevectors, chars, lex, lex_r7rs,
            lists, Math, numbers, pairs, strings, symbols, vectors,
            debug=True)
