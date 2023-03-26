from ._loader import init_module
from . import strings

init_module(globals(), 'lex', strings)
