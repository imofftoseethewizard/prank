from .._loader import init_module
from . import block_mgr, chars, pairs

init_module(globals(), 'strings', block_mgr, chars, pairs, debug=True)
