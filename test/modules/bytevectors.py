from ._loader import init_module
from . import block_mgr, lists, pairs

init_module(globals(), 'bytevectors', block_mgr, lists, pairs)
