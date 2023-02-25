from util import format_addr
from modules.debug.block_mgr import *
from modules.debug.bytevectors import *
from modules.debug.pairs import *

NULL = NULL.value

def init_test():
    init_pairs()
    init_blockset_manager()
    init_bytevectors()

def test_init():
    init_test()

def test_alloc():
    init_test()
    bv = alloc_bytevector(5)
    assert get_bytevector_size(bv) == 5

def test_dealloc():
    init_test()
    bv = alloc_bytevector(5)
    dealloc_bytevector(bv)

def test_get_and_set_i8_u():
    init_test()
    bv = alloc_bytevector(5)

    for i in range(5):
        set_bytevector_i8(bv, i, i*10)

    for i in range(5):
        assert get_bytevector_i8_u(bv, i) == i*10

    try:
        get_bytevector_i8_u(bv, 10)
        assert False
    except:
        ...

    try:
        get_bytevector_i8_u(bv, -1)
        assert False
    except:
        ...

    try:
        set_bytevector_i8_u(bv, 10, 0)
        assert False
    except:
        ...

    try:
        set_bytevector_i8_u(bv, -1, 0)
        assert False
    except:
        ...
