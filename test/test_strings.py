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

def test_calc_idx_mask():
    assert calc_idx_mask(make_string_type(5, 5)) == 0xff
    assert calc_idx_mask(make_string_type(5, 10)) == 0xff
    assert calc_idx_mask(make_string_type(300, 300)) == 0xffff
    assert calc_idx_mask(make_string_type(300_000, 300_000)) == -1

def test_alloc():
    init_test()
    s = alloc_string(5, 7)
    print(format_addr(get_pair_car(s)))
    assert get_string_length(s) == 5
    assert get_string_size(s) == 7

def test_dealloc():
    init_test()
    s = alloc_string(10, 10)
    dealloc_string(s)

def test_set_string_bytes():
    init_test()
    s = alloc_string(10, 10)
    addr = get_string_addr(s)
    set_string_bytes(addr, 0x45, 1)
    assert get_string_bytes(addr, 1) == 0x45
    set_string_bytes(addr+1, 0x9045, 2)
    assert get_string_bytes(addr+1, 2) == 0x9045
    set_string_bytes(addr+2, 0x7a9045, 3)
    assert get_string_bytes(addr, 3) == 0x454545
    set_string_bytes(addr, 0x04030201, 4)
    assert get_string_bytes(addr+1, 4) == 0x7a040302

def test_build_small_string_index():
    init_test()
    s = alloc_string(100, 100)
    addr = get_string_addr(s)
    for i in range(100):
        set_string_bytes(addr+i, i % 10 + ord('0'), 1)

    assert get_string_size(s) == 100
    assert get_string_length(s) == 100

    build_small_string_index(s)

def test_string_hash():
    init_test()

    def init_string(L):
        s = alloc_string(L, L)
        addr = get_string_addr(s)
        for i in range(L):
            set_string_bytes(addr+i, i % 10 + ord('0'), 1)
        return s

    hashes = set(hash_string(init_string(i)) for i in range(100))
    assert len(hashes) == 100

def test_inter_1k_hashes():
    init_test()

    results = []
    hashes = set()
    for i in range(1000):
        text = str(i)
        k = len(text)
        s = alloc_string(k, k)
        addr = get_string_addr(s)
        for j in range(k):
            set_string_bytes(addr+j, ord(text[j]), 1)
        hash = hash_string(s)
        hashes.add(hash)
        results.append((i, text, s, hash))

    assert len(hashes) == 1000

def test_string_equal():
    init_test()

    s1 = alloc_string(1, 1)
    print(format_addr(s1))
    s1_addr = get_string_addr(s1)
    print(format_addr(s1_addr))
    print(format_addr(get_pair_car(s1)))
    print(format_addr(get_pair_cdr(s1)))
    print(format_addr(get_pair_cdar(s1)))
    print(format_addr(get_pair_cddr(s1)))
    print(format_addr(get_pair_cdaar(s1)))
    print(format_addr(get_pair_cdadr(s1)))
    set_string_bytes(s1_addr, ord('a'), 1)
    assert get_string_bytes(s1_addr, 1) == ord('a')

    s2 = alloc_string(1, 1)
    print(format_addr(s2))
    s2_addr = get_string_addr(s2)
    print(format_addr(s2_addr))
    print(format_addr(get_pair_car(s2)))
    print(format_addr(get_pair_cdr(s2)))
    print(format_addr(get_pair_cdar(s2)))
    print(format_addr(get_pair_cddr(s2)))
    print(format_addr(get_pair_cdaar(s2)))
    print(format_addr(get_pair_cdadr(s2)))
    set_string_bytes(s2_addr, ord('a'), 1)
    assert get_string_bytes(s2_addr, 1) == ord('a')

    # print(s1)
    # print(s2)
    # print(s1_addr)
    # print(s2_addr)
    # print(string_equal(s1, s2))
