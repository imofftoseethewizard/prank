from ._loader import init_module
from . import block_mgr, chars, lists, pairs

init_module(globals(), 'strings', block_mgr, chars, lists, pairs)
