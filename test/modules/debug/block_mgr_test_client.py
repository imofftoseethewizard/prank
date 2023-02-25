from .._loader import init_module
from . import block_mgr

init_module(globals(), 'block-mgr-test-client', block_mgr, debug=True)
