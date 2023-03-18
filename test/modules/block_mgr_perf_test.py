from ._loader import init_module
from . import block_mgr

init_module(globals(), 'block-mgr-perf-test', block_mgr)
