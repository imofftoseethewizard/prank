from util import format_addr
from modules.debug.block_mgr import *
from modules.debug.strings import *
from modules.debug.pairs import *

NULL = NULL.value

def init_test():
    init_pairs()
    init_blockset_manager()
    init_strings()

def test_init():
    init_test()

def test_alloc():
    init_test()
    s = alloc_string(5, 7)
    assert get_string_length(s) == 5
    assert get_string_size(s) == 7

def test_dealloc():
    init_test()
    s = alloc_string(10, 10)
    dealloc_string(s)
