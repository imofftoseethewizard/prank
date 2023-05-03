from .._loader import init_module
from . import lex, strings

init_module(globals(), 'lex-r7rs', lex, strings, debug=True)
