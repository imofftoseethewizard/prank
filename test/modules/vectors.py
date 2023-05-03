from ._loader import init_module
from . import block_mgr, lists, pairs

init_module(globals(), 'vectors', block_mgr, lists, pairs)
