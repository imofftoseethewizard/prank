from .._loader import init_module
from . import block_mgr, pairs

init_module(globals(), 'numbers', block_mgr, pairs, debug=True)
