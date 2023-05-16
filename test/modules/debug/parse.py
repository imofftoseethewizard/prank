from wasmer import FunctionType, Type

from .._loader import function, init_module
from . import bytevectors, chars, lex, lex_r7rs, lists, numbers, pairs, strings, symbols, vectors

import math

def cos(x: float) -> float:
    return math.cos(x)

def sin(x: float) -> float:
    return math.sin(x)

class Math:
    __module_name__ = 'math'
    __exports__ = {
        'cos': function(cos, FunctionType([Type.F64], [Type.F64])),
        'sin': function(sin, FunctionType([Type.F64], [Type.F64])),
    }

init_module(globals(), 'parse', bytevectors, chars, lex, lex_r7rs,
            lists, Math, numbers, pairs, strings, symbols, vectors,
            debug=True)
