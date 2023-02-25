from modules.debug.pairs import *

def test_init_pairs():
    init_pairs()
    assert pairs_top.value == 0
    assert pair_count.value == 0
    assert pair_free_list.value == NULL.value

def test_alloc_pair():
    init_pairs()
    p = alloc_pair()
    assert pair_count.value == 1

def test_dealloc_pair():
    init_pairs()
    dealloc_pair(alloc_pair())
    assert pair_count.value == 0

def test_set_pair_car():
    init_pairs()
    p = alloc_pair()
    set_pair_car(p, 15)
    assert get_pair_car(p) == 15

def test_set_pair_cdr():
    init_pairs()
    p = alloc_pair()
    set_pair_cdr(p, 15)
    assert get_pair_cdr(p) == 15

def test_make_pair():
    init_pairs()
    p = make_pair(1, 2)
    assert get_pair_car(p) == 1
    assert get_pair_cdr(p) == 2

def test_alloc_64K_pairs():
    init_pairs()
    ps = [alloc_pair() for i in range(2**16)]
    assert len(set(ps)) == len(ps)

def test_alloc_dealloc_64K_pairs():
    init_pairs()
    ps = [alloc_pair() for i in range(2**16)]
    for p in ps:
        dealloc_pair(p)
    assert pair_count.value == 0

def test_alloc_dealloc_alloc_64K_pairs():
    init_pairs()
    ps = [alloc_pair() for i in range(2**16)]
    for p in ps:
        dealloc_pair(p)
    assert pair_count.value == 0
    ps = [alloc_pair() for i in range(2**16)]
    assert len(set(ps)) == len(ps)

def test_make_1K_pairs():
    init_pairs()
    ps = [make_pair(2*i, 2*i+1) for i in range(2**10)]
    for i, p in enumerate(ps):
        assert get_pair_car(p) == 2*i
        assert get_pair_cdr(p) == 2*i+1

def test_get_pair_caar():
    p = make_pair(make_pair(1, 0), 0)
    assert get_pair_caar(p) == 1

def test_get_pair_cadr():
    p = make_pair(make_pair(0, 1), 0)
    assert get_pair_cadr(p) == 1

def test_get_pair_cdar():
    p = make_pair(0, make_pair(1, 0))
    assert get_pair_cdar(p) == 1

def test_get_pair_cddr():
    p = make_pair(0, make_pair(0, 1))
    assert get_pair_cddr(p) == 1

def test_get_pair_caaar():
    p = make_pair(make_pair(make_pair(1, 0), 0), 0)
    assert get_pair_caaar(p) == 1

def test_get_pair_caadr():
    p = make_pair(make_pair(make_pair(0, 1), 0), 0)
    assert get_pair_caadr(p) == 1

def test_get_pair_cadar():
    p = make_pair(make_pair(0, make_pair(1, 0)), 0)
    assert get_pair_cadar(p) == 1

def test_get_pair_caddr():
    p = make_pair(make_pair(0, make_pair(0, 1)), 0)
    assert get_pair_caddr(p) == 1

def test_get_pair_cdaar():
    p = make_pair(0, make_pair(make_pair(1, 0), 0))
    assert get_pair_cdaar(p) == 1

def test_get_pair_cdadr():
    p = make_pair(0, make_pair(make_pair(0, 1), 0))
    assert get_pair_cdadr(p) == 1

def test_get_pair_cddar():
    p = make_pair(0, make_pair(0, make_pair(1, 0)))
    assert get_pair_cddar(p) == 1

def test_get_pair_cdddr():
    p = make_pair(0, make_pair(0, make_pair(0, 1)))
    assert get_pair_cdddr(p) == 1

def test_set_pair_car():
    p = make_pair(0, 0)
    set_pair_car(p, 1)
    assert get_pair_car(p) == 1

def test_set_pair_cdr():
    p = make_pair(0, 0)
    set_pair_cdr(p, 1)
    assert get_pair_cdr(p) == 1

def test_set_pair_caar():
    p = make_pair(make_pair(0, 0), make_pair(0, 0))
    set_pair_caar(p, 1)
    assert get_pair_caar(p) == 1

def test_set_pair_cadr():
    p = make_pair(make_pair(0, 0), make_pair(0, 0))
    set_pair_cadr(p, 1)
    assert get_pair_cadr(p) == 1

def test_set_pair_cdar():
    p = make_pair(make_pair(0, 0), make_pair(0, 0))
    set_pair_cdar(p, 1)
    assert get_pair_cdar(p) == 1

def test_set_pair_cddr():
    p = make_pair(make_pair(0, 0), make_pair(0, 0))
    set_pair_cddr(p, 1)
    assert get_pair_cddr(p) == 1

def test_set_pair_caaar():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_caaar(p, 1)
    assert get_pair_caaar(p) == 1

def test_set_pair_caadr():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_caadr(p, 1)
    assert get_pair_caadr(p) == 1

def test_set_pair_cadar():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_cadar(p, 1)
    assert get_pair_cadar(p) == 1

def test_set_pair_caddr():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_caddr(p, 1)
    assert get_pair_caddr(p) == 1

def test_set_pair_cdaar():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_cdaar(p, 1)
    assert get_pair_cdaar(p) == 1

def test_set_pair_cdadr():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_cdadr(p, 1)
    assert get_pair_cdadr(p) == 1

def test_set_pair_cddar():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_cddar(p, 1)
    assert get_pair_cddar(p) == 1

def test_set_pair_cdddr():
    p = make_pair(make_pair(make_pair(0, 0), make_pair(0, 0)),
                        make_pair(make_pair(0, 0), make_pair(0, 0)))
    set_pair_cdddr(p, 1)
    assert get_pair_cdddr(p) == 1
