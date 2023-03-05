from util import format_addr
from modules.debug.pairs import *
from modules.debug.block_mgr import *
from modules.debug.strings import *
from modules.debug.symbols import *

NULL = NULL.value

def init_test():
    init_pairs()
    init_blockset_manager()
    init_strings()
    init_symbols()

def test_init():
    init_test()

def test_inter_symbol():
    init_test()

    s = alloc_string(1, 1)
    set_string_bytes(s, ord('a'), 1)
    sym = inter_symbol(s)

def test_inter_symbol_match():
    init_test()

    s1 = alloc_string(1, 1)
    set_string_bytes(s1, ord('a'), 1)
    sym1 = inter_symbol(s1)

    s2 = alloc_string(1, 1)
    set_string_bytes(s2, ord('a'), 1)
    sym2 = inter_symbol(s2)

    assert s1 != s2
    assert sym1 == sym2

def test_inter_1k_symbols():
    init_test()

    results = []
    syms = set()
    for i in range(1000):
        text = str(i)
        k = len(text)
        s = alloc_string(k, k)
        addr = get_string_addr(s)
        for j in range(k):
            set_string_bytes(addr+j, ord(text[j]), i)
        sym = inter_symbol(s)
        syms.add(sym)
        results.append((i, text, s, sym))

    for idx, text, s, sym in results:
        print(idx, text, s, sym)

    assert len(syms) == 1000
