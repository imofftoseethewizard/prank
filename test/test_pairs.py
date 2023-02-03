from modules import lists, pairs, values

def test_init_pairs():
    pairs.init_pairs()
    assert pairs.pairs_top.value == 0
    assert pairs.pair_count.value == 0
    assert pairs.pair_free_list.value == pairs.NULL.value

def test_alloc_pair():
    pairs.init_pairs()
    p = pairs.alloc_pair()
    assert pairs.pair_count.value == 1

def test_dealloc_pair():
    pairs.init_pairs()
    pairs.dealloc_pair(pairs.alloc_pair())
    assert pairs.pair_count.value == 0

def test_set_pair_car():
    pairs.init_pairs()
    p = pairs.alloc_pair()
    pairs.set_pair_car(p, 15)
    assert pairs.get_pair_car(p) == 15

def test_set_pair_cdr():
    pairs.init_pairs()
    p = pairs.alloc_pair()
    pairs.set_pair_cdr(p, 15)
    assert pairs.get_pair_cdr(p) == 15

def test_make_pair():
    pairs.init_pairs()
    p = pairs.make_pair(1, 2)
    assert pairs.get_pair_car(p) == 1
    assert pairs.get_pair_cdr(p) == 2

def test_alloc_64K_pairs():
    pairs.init_pairs()
    ps = [pairs.alloc_pair() for i in range(2**16)]
    assert len(set(ps)) == len(ps)

def test_alloc_dealloc_64K_pairs():
    pairs.init_pairs()
    ps = [pairs.alloc_pair() for i in range(2**16)]
    for p in ps:
        pairs.dealloc_pair(p)
    assert pairs.pair_count.value == 0

def test_alloc_dealloc_alloc_64K_pairs():
    pairs.init_pairs()
    ps = [pairs.alloc_pair() for i in range(2**16)]
    for p in ps:
        pairs.dealloc_pair(p)
    assert pairs.pair_count.value == 0
    ps = [pairs.alloc_pair() for i in range(2**16)]
    assert len(set(ps)) == len(ps)

def test_make_1K_pairs():
    pairs.init_pairs()
    ps = [pairs.make_pair(2*i, 2*i+1) for i in range(2**10)]
    for i, p in enumerate(ps):
        assert pairs.get_pair_car(p) == 2*i
        assert pairs.get_pair_cdr(p) == 2*i+1

def test_get_pair_caar():
    p = pairs.make_pair(pairs.make_pair(1, 0), 0)
    assert pairs.get_pair_caar(p) == 1

def test_get_pair_cadr():
    p = pairs.make_pair(pairs.make_pair(0, 1), 0)
    assert pairs.get_pair_cadr(p) == 1

def test_get_pair_cdar():
    p = pairs.make_pair(0, pairs.make_pair(1, 0))
    assert pairs.get_pair_cdar(p) == 1

def test_get_pair_cddr():
    p = pairs.make_pair(0, pairs.make_pair(0, 1))
    assert pairs.get_pair_cddr(p) == 1

def test_get_pair_caaar():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(1, 0), 0), 0)
    assert pairs.get_pair_caaar(p) == 1

def test_get_pair_caadr():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 1), 0), 0)
    assert pairs.get_pair_caadr(p) == 1

def test_get_pair_cadar():
    p = pairs.make_pair(pairs.make_pair(0, pairs.make_pair(1, 0)), 0)
    assert pairs.get_pair_cadar(p) == 1

def test_get_pair_caddr():
    p = pairs.make_pair(pairs.make_pair(0, pairs.make_pair(0, 1)), 0)
    assert pairs.get_pair_caddr(p) == 1

def test_get_pair_cdaar():
    p = pairs.make_pair(0, pairs.make_pair(pairs.make_pair(1, 0), 0))
    assert pairs.get_pair_cdaar(p) == 1

def test_get_pair_cdadr():
    p = pairs.make_pair(0, pairs.make_pair(pairs.make_pair(0, 1), 0))
    assert pairs.get_pair_cdadr(p) == 1

def test_get_pair_cddar():
    p = pairs.make_pair(0, pairs.make_pair(0, pairs.make_pair(1, 0)))
    assert pairs.get_pair_cddar(p) == 1

def test_get_pair_cdddr():
    p = pairs.make_pair(0, pairs.make_pair(0, pairs.make_pair(0, 1)))
    assert pairs.get_pair_cdddr(p) == 1

def test_set_pair_car():
    p = pairs.make_pair(0, 0)
    pairs.set_pair_car(p, 1)
    assert pairs.get_pair_car(p) == 1

def test_set_pair_cdr():
    p = pairs.make_pair(0, 0)
    pairs.set_pair_cdr(p, 1)
    assert pairs.get_pair_cdr(p) == 1

def test_set_pair_caar():
    p = pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0))
    pairs.set_pair_caar(p, 1)
    assert pairs.get_pair_caar(p) == 1

def test_set_pair_cadr():
    p = pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0))
    pairs.set_pair_cadr(p, 1)
    assert pairs.get_pair_cadr(p) == 1

def test_set_pair_cdar():
    p = pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0))
    pairs.set_pair_cdar(p, 1)
    assert pairs.get_pair_cdar(p) == 1

def test_set_pair_cddr():
    p = pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0))
    pairs.set_pair_cddr(p, 1)
    assert pairs.get_pair_cddr(p) == 1

def test_set_pair_caaar():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_caaar(p, 1)
    assert pairs.get_pair_caaar(p) == 1

def test_set_pair_caadr():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_caadr(p, 1)
    assert pairs.get_pair_caadr(p) == 1

def test_set_pair_cadar():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_cadar(p, 1)
    assert pairs.get_pair_cadar(p) == 1

def test_set_pair_caddr():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_caddr(p, 1)
    assert pairs.get_pair_caddr(p) == 1

def test_set_pair_cdaar():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_cdaar(p, 1)
    assert pairs.get_pair_cdaar(p) == 1

def test_set_pair_cdadr():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_cdadr(p, 1)
    assert pairs.get_pair_cdadr(p) == 1

def test_set_pair_cddar():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_cddar(p, 1)
    assert pairs.get_pair_cddar(p) == 1

def test_set_pair_cdddr():
    p = pairs.make_pair(pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)),
                        pairs.make_pair(pairs.make_pair(0, 0), pairs.make_pair(0, 0)))
    pairs.set_pair_cdddr(p, 1)
    assert pairs.get_pair_cdddr(p) == 1
