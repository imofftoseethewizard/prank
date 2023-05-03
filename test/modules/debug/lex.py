from .._loader import init_module
from . import chars, strings

init_module(globals(), 'lex', chars, strings, debug=True)
