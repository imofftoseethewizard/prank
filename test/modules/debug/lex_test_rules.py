from .._loader import init_module
from . import lex, strings

init_module(globals(), 'lex-test-rules', lex, strings, debug=True)
