from ._loader import init_module
from . import block_mgr, strings

init_module(globals(), 'symbols', block_mgr, strings)
