from itertools import zip_longest

from modules import block_mgr, block_mgr_test_client, lists, pairs, values

blockset_id = 7
blockset = block_mgr.get_blockset(blockset_id)

NULL = block_mgr.NULL.value

def list_allocated_pairs():
    addrs = []
    free_addrs = set()

    free_pair = pairs.pair_free_list.value
    while free_pair != NULL:
        free_addrs.add(free_pair)
        free_pair = pairs.get_pair_car(free_pair)

    for addr in range(0, pairs.pairs_top.value, pairs.pair_size.value):
        if addr not in free_addrs:
            addrs.append(addr)

    print('allocated pairs:')

    for pair in addrs:
        print(f'{format_addr(pair)}: ({format_addr(pairs.get_pair_car(pair))} . {format_addr(pairs.get_pair_cdr(pair))})')

def print_all():
    list_allocated_pairs()
    print()
    print_blockset()

def print_blockset():
    print('state:')
    print_block_mgr_state()
    print()

    print('block list:')
    print_block_list()
    print()

    print('free list:')
    print_free_list()
    print()

    print('heap:')
    print_heap()
    print()

def validate_blockset():

    try:
        validate_block_list()
        validate_free_list()
        validate_heap()

        block_count = block_mgr.get_blockset_block_count(blockset)
        free_list_length = block_mgr.get_blockset_free_list_length(blockset)
        heap_size = block_mgr.get_blockset_heap_size(blockset)
        pair_count = pairs.pair_count.value

        assert pair_count == 6*heap_size + 2*(block_count - free_list_length)

    except:
        list_allocated_pairs()
        print()
        print_blockset()
        raise

def validate_block_list():

    block_count = block_mgr.get_blockset_block_count(blockset)
    block_list = block_mgr.get_blockset_block_list(blockset)

    assert lists.get_list_length(block_list) == block_count

    last = NULL
    addr = 0
    ref = block_list
    while ref != NULL:
        assert block_mgr.get_block_ref_addr(ref) == addr
        addr += block_mgr.get_block_ref_size(ref)
        last = ref
        ref = pairs.get_pair_cdr(ref)

    assert block_mgr.get_blockset_end_block_ref(blockset) == last

def validate_free_list():

    block_list = block_mgr.get_blockset_block_list(blockset)
    free_list = block_mgr.get_blockset_free_list(blockset)
    free_list_length = block_mgr.get_blockset_free_list_length(blockset)

    assert lists.get_list_length(free_list) == free_list_length

    refs = []
    ref = block_list
    while ref != NULL:
        refs.append(ref)
        ref = pairs.get_pair_cdr(ref)

    entry = free_list
    last_free_addr = -1
    while entry != NULL:
        assert pairs.get_pair_car(entry) in refs
        free_addr = block_mgr.get_free_entry_addr(entry)
        assert free_addr  > last_free_addr
        last_free_addr = free_addr
        entry = pairs.get_pair_cdr(entry)

def validate_heap():

    free_list = block_mgr.get_blockset_free_list(blockset)
    heap = block_mgr.get_blockset_heap(blockset)
    heap_size = block_mgr.get_blockset_heap_size(blockset)

    free_entries = []
    entry = free_list
    while entry != NULL:
        free_entries.append(entry)
        entry = pairs.get_pair_cdr(entry)

    size = 0

    def validate_node(node, parent_size=None):
        if node != NULL:
            nonlocal size
            size += 1

            assert (
                block_mgr.get_heap_node_entry(node) in free_entries
                or block_mgr.is_unused_heap_block(node)
            )

            entry = block_mgr.get_heap_node_entry(node)
            assert pairs.get_pair_car(node) == pairs.get_pair_caar(entry)

            node_size = block_mgr.get_heap_block_size(node)
            assert node_size == block_mgr.get_free_entry_size(entry)

            if parent_size is not None:
                assert node_size <= parent_size

            validate_node(block_mgr.get_heap_left(node), node_size)
            validate_node(block_mgr.get_heap_right(node), node_size)

    validate_node(heap)

    assert size == heap_size

def print_block_mgr_state():
    print("get_blockset_block_count:", block_mgr.get_blockset_block_count(blockset))
    print("get_blockset_block_list:", format_addr(block_mgr.get_blockset_block_list(blockset)))
    print("get_blockset_defrag_cursor:", format_addr(block_mgr.get_blockset_defrag_cursor(blockset)))
    print("get_blockset_end_block_ref:", format_addr(block_mgr.get_blockset_end_block_ref(blockset)))
    print("get_blockset_heap:", format_addr(block_mgr.get_blockset_heap(blockset)))
    print("get_blockset_heap_size:", block_mgr.get_blockset_heap_size(blockset))
    print("get_blockset_free_list:", format_addr(block_mgr.get_blockset_free_list(blockset)))
    print("get_blockset_free_list_length:", block_mgr.get_blockset_free_list_length(blockset))

def print_heap():
    for s in format_heap_node(block_mgr.get_blockset_heap(blockset)):
        print(s)
    print()

def format_addr(addr):
    return 'NULL' if addr == NULL else hex(addr)

def format_heap_node(n):
    if n == NULL:
        return []

    f_l = format_heap_node(block_mgr.get_heap_left(n))
    f_r = format_heap_node(block_mgr.get_heap_right(n))

    width_l = len(f_l[0]) if f_l else 0
    width_r = len(f_r[0]) if f_r else 0

    size = block_mgr.get_heap_block_size(n)
    addr = block_mgr.get_heap_block_addr(n)

    s = f'{format_addr(n)}: {size} @ {format_addr(addr)}'

    total_width = max(len(s), width_l + width_r + 3)

    s0 = s + ' ' * (total_width - len(s))

    blank_l = ' ' * width_l
    blank_r = ' ' * width_r
    return [
        s0,
        *[
            (l or blank_l) + ' | ' + (r or blank_r)
            for l, r in zip_longest(f_l, f_r)
        ]
    ]

def print_block_list():

    ref = block_mgr.get_blockset_block_list(blockset)

    while ref != NULL:

        addr = block_mgr.get_block_ref_addr(ref)
        size = block_mgr.get_block_ref_size(ref)

        print(f'{format_addr(ref)}: {format_addr(addr)} [{size}]')

        ref = pairs.get_pair_cdr(ref)

def print_free_list():

    entry = block_mgr.get_blockset_free_list(blockset)

    while entry != NULL:

        addr = block_mgr.get_block_ref_addr(pairs.get_pair_car(entry))
        size = block_mgr.get_block_ref_size(pairs.get_pair_car(entry))

        print(f'{format_addr(entry)}: {size} @ {format_addr(addr)}')

        entry = pairs.get_pair_cdr(entry)

def test_init_block_mgr():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_block_count(blockset) == 0
    assert block_mgr.get_blockset_block_list(blockset) == NULL
    assert block_mgr.get_blockset_defrag_cursor(blockset) == NULL
    assert block_mgr.get_blockset_end_block_ref(blockset) == NULL
    assert block_mgr.get_blockset_heap(blockset) == NULL
    assert block_mgr.get_blockset_heap_size(blockset) == 0
    assert block_mgr.get_blockset_free_list(blockset) == NULL
    assert block_mgr.get_blockset_free_list_length(blockset) == 0

def test_get_blockset_id():
    assert block_mgr.get_blockset_id(blockset) == blockset_id
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(1)) == 1
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(2)) == 2
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(3)) == 3

def test_set_blockset_block_count():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_block_count(blockset) == 0
    block_mgr.set_blockset_block_count(blockset, 1)
    assert block_mgr.get_blockset_block_count(blockset) == 1

def test_set_blockset_block_list():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_block_list(blockset) == NULL
    block_mgr.set_blockset_block_list(blockset, 1)
    assert block_mgr.get_blockset_block_list(blockset) == 1

def test_set_blockset_defrag_cursor():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_defrag_cursor(blockset) == NULL
    block_mgr.set_blockset_defrag_cursor(blockset, 1)
    assert block_mgr.get_blockset_defrag_cursor(blockset) == 1

def test_set_blockset_end_block_ref():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_end_block_ref(blockset) == NULL
    block_mgr.set_blockset_end_block_ref(blockset, 1)
    assert block_mgr.get_blockset_end_block_ref(blockset) == 1

def test_set_blockset_heap():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_heap(blockset) == NULL
    block_mgr.set_blockset_heap(blockset, 1)
    assert block_mgr.get_blockset_heap(blockset) == 1

def test_set_blockset_heap_size():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_heap_size(blockset) == 0
    block_mgr.set_blockset_heap_size(blockset, 1)
    assert block_mgr.get_blockset_heap_size(blockset) == 1

def test_set_blockset_free_list():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_free_list(blockset) == NULL
    block_mgr.set_blockset_free_list(blockset, 1)
    assert block_mgr.get_blockset_free_list(blockset) == 1

def test_set_blockset_free_list_length():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_free_list_length(blockset) == 0
    block_mgr.set_blockset_free_list_length(blockset, 1)
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

def test_set_blockset_immobile_block_size():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_immobile_block_size(blockset) == 0x2000
    block_mgr.set_blockset_immobile_block_size(blockset, 1)
    assert block_mgr.get_blockset_immobile_block_size(blockset) == 1

def test_set_blockset_relocation_size_limit():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_relocation_size_limit(blockset) == 0x1000
    block_mgr.set_blockset_relocation_size_limit(blockset, 1)
    assert block_mgr.get_blockset_relocation_size_limit(blockset) == 1

def test_decr_blockset_block_count():
    block_mgr_test_client.init(blockset_id)
    block_mgr.set_blockset_block_count(blockset, 1)
    block_mgr.decr_blockset_block_count(blockset)
    assert block_mgr.get_blockset_block_count(blockset) == 0

def test_decr_blockset_heap_size():
    block_mgr_test_client.init(blockset_id)
    block_mgr.set_blockset_heap_size(blockset, 1)
    block_mgr.decr_blockset_heap_size(blockset)
    assert block_mgr.get_blockset_heap_size(blockset) == 0

def test_decr_blockset_free_list_length():
    block_mgr_test_client.init(blockset_id)
    block_mgr.set_blockset_free_list_length(blockset, 1)
    block_mgr.decr_blockset_free_list_length(blockset)
    assert block_mgr.get_blockset_free_list_length(blockset) == 0

def test_incr_blockset_block_count():
    block_mgr_test_client.init(blockset_id)
    block_mgr.set_blockset_block_count(blockset, 1)
    block_mgr.incr_blockset_block_count(blockset)
    assert block_mgr.get_blockset_block_count(blockset) == 2

def test_incr_blockset_heap_size():
    block_mgr_test_client.init(blockset_id)
    block_mgr.set_blockset_heap_size(blockset, 1)
    block_mgr.incr_blockset_heap_size(blockset)
    assert block_mgr.get_blockset_heap_size(blockset) == 2

def test_incr_blockset_free_list_length():
    block_mgr_test_client.init(blockset_id)
    block_mgr.set_blockset_free_list_length(blockset, 1)
    block_mgr.incr_blockset_free_list_length(blockset)
    assert block_mgr.get_blockset_free_list_length(blockset) == 2

def test_make_block():
    b = block_mgr.make_block(64, 4)
    assert block_mgr.get_block_addr(b) == 64
    assert block_mgr.get_block_size(b) == 4

def test_get_next_block_addr():
    b = block_mgr.make_block(64, 4)
    assert block_mgr.get_next_block_addr(b) == 68

def test_set_block_addr():
    b = block_mgr.make_block(64, 4)
    block_mgr.set_block_addr(b, 72)
    assert block_mgr.get_block_addr(b) == 72

def test_set_block_size():
    b = block_mgr.make_block(64, 4)
    block_mgr.set_block_size(b, 8)
    assert block_mgr.get_block_size(b) == 8

def test_block_ref_accessors():
    r = pairs.make_pair(block_mgr.make_block(64, 4), NULL)
    assert block_mgr.get_block_ref_addr(r) == 64
    assert block_mgr.get_block_ref_size(r) == 4

def test_set_block_ref_addr():
    r = pairs.make_pair(block_mgr.make_block(64, 4), NULL)
    block_mgr.set_block_ref_addr(r, 72)
    assert block_mgr.get_block_ref_addr(r) == 72

def test_set_block_ref_size():
    r = pairs.make_pair(block_mgr.make_block(64, 4), NULL)
    block_mgr.set_block_ref_size(r, 8)
    assert block_mgr.get_block_ref_size(r) == 8

def test_block_ref_accessors():
    e = pairs.make_pair(pairs.make_pair(block_mgr.make_block(64, 4), NULL), NULL)
    assert block_mgr.get_free_entry_addr(e) == 64
    assert block_mgr.get_free_entry_size(e) == 4

def test_set_free_entry_addr():
    e = pairs.make_pair(pairs.make_pair(block_mgr.make_block(64, 4), NULL), NULL)
    block_mgr.set_free_entry_addr(e, 72)
    assert block_mgr.get_free_entry_addr(e) == 72

def test_make_heap_node():
    b = block_mgr.make_block(64, 4)
    r = pairs.make_pair(b, NULL)
    e = pairs.make_pair(r, NULL)
    n = block_mgr.make_heap_node(e)
    assert block_mgr.get_heap_block(n) == b
    assert block_mgr.get_heap_block_addr(n) == 64
    assert block_mgr.get_heap_block_size(n) == 4
    assert block_mgr.get_heap_node_entry(n) == e
    assert block_mgr.get_heap_left(n) == NULL
    assert block_mgr.get_heap_right(n) == NULL

def test_alloc_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 48)
    assert block_mgr.get_block_ref_size(b) == 48
    validate_blockset()

def test_alloc_2_blocks():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b0 = block_mgr.alloc_block(blockset_id, 1024)
    assert block_mgr.get_block_ref_size(b0) == 1024
    b1 = block_mgr.alloc_block(blockset_id, 1024)
    assert block_mgr.get_block_ref_size(b1) == 1024
    assert block_mgr.get_block_addr(b0) != block_mgr.get_block_addr(b1)
    validate_blockset()

def test_alloc_64k_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 1<<16)
    assert block_mgr.get_block_ref_size(b) == 1<<16
    validate_blockset()

def test_alloc_128k_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 1<<17)
    assert block_mgr.get_block_ref_size(b) == 1<<17
    validate_blockset()

def test_alloc_128_1k_blocks():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    bs = [
        block_mgr.alloc_block(blockset_id, 1024)
        for i in range(128)
    ]
    assert len(bs) == len(set(block_mgr.get_block_addr(b) for b in bs))
    validate_blockset()

def test_dealloc_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 256)
    block_mgr.dealloc_block(blockset_id, b)
    validate_blockset()

def test_alloc_dealloc_64k_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.dealloc_block(blockset_id, b)
    validate_blockset()

def test_alloc_dealloc_128k_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 1<<17)
    block_mgr.dealloc_block(blockset_id, b)
    validate_blockset()

def test_alloc_dealloc_128_1k_blocks():
    N = 128

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    bs = [
        block_mgr.alloc_block(blockset_id, 1024)
        for i in range(N)
    ]

    for b in bs:
        block_mgr.dealloc_block(blockset_id, b)
        validate_blockset()

def test_alloc_dealloc_alloc_64k_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)
    b = block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.dealloc_block(blockset_id, b)
    b = block_mgr.alloc_block(blockset_id, 1<<16)
    validate_blockset()

def test_calc_heap_traversal_mask():
    assert block_mgr.calc_heap_traversal_mask(1) == 0x00
    assert block_mgr.calc_heap_traversal_mask(2) == 0x01
    assert block_mgr.calc_heap_traversal_mask(3) == 0x01
    assert block_mgr.calc_heap_traversal_mask(4) == 0x02
    assert block_mgr.calc_heap_traversal_mask(5) == 0x02

def test_alloc_dealloc_alloc_64_1k_blocks():
    N = 1024
    k = 64

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]
    for b in bs:
        block_mgr.dealloc_block(blockset_id, b)

    for i in range(k):
        block_mgr.alloc_block(blockset_id, N)

    validate_blockset()

def test_alloc_dealloc_linear_sized_blocks():
    N = 1024
    k = 64

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    bs = [
        block_mgr.alloc_block(blockset_id, i*N)
        for i in range(1, k)
    ]

    for b in bs:
        validate_blockset()
        block_mgr.dealloc_block(blockset_id, b)

    validate_blockset()

    bs = [
        block_mgr.alloc_block(blockset_id, i*N)
        for i in range(1, k)
    ]

    validate_blockset()

def test_defrag_empty():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

def test_defrag_one_alloc_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

def test_defrag_one_small_alloc_one_free_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.alloc_block(blockset_id, 48)
    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

def test_defrag_two_free_blocks():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b = block_mgr.alloc_block(blockset_id, 48)
    block_mgr.dealloc_block(blockset_id, b)

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

def test_defrag_two_small_alloc_three_free_blocks():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b0 = block_mgr.alloc_block(blockset_id, 48)
    b1 = block_mgr.alloc_block(blockset_id, 48)
    b2 = block_mgr.alloc_block(blockset_id, 48)
    b3 = block_mgr.alloc_block(blockset_id, 48)

    block_mgr.dealloc_block(blockset_id, b0)
    block_mgr.dealloc_block(blockset_id, b2)

    validate_blockset()

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

def test_defrag_two_small_alloc_three_free_blocks():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b0 = block_mgr.alloc_block(blockset_id, 48)
    b1 = block_mgr.alloc_block(blockset_id, 48)
    b2 = block_mgr.alloc_block(blockset_id, 48)
    b3 = block_mgr.alloc_block(blockset_id, 48)

    block_mgr.dealloc_block(blockset_id, b0)
    block_mgr.dealloc_block(blockset_id, b2)

    validate_blockset()

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

def test_defrag_several_deallocated_blocks():

    N = 256
    k = 64

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]

    for b in bs:
        block_mgr.dealloc_block(blockset_id, b)

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_defrag_cursor(blockset) != NULL and count < k:

        block_mgr.step_defragment_blockset(blockset)

        validate_blockset()

        count += 1

    assert count < k

def test_defrag_many_1k_blocks():

    N = 1024
    k = 96

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    validate_blockset()

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]

    remaining_blocks = []
    for i, b in enumerate(bs):
        if i % 2:
            block_mgr.dealloc_block(blockset_id, b)
            validate_blockset()
        else:
            remaining_blocks.append(b)

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_defrag_cursor(blockset) != NULL and count < k:

        block_mgr.step_defragment_blockset(blockset)

        validate_blockset()

        count += 1

    assert count < k
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    last_blocks = []
    for i, b in enumerate(remaining_blocks):
        if i % 2 == 0:
            block_mgr.dealloc_block(blockset_id, b)
            validate_blockset()
        else:
            last_blocks.append(b)

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_defrag_cursor(blockset) != NULL and count < k:

        block_mgr.step_defragment_blockset(blockset)

        validate_blockset()

        count += 1

    assert count < k/2
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    for b in last_blocks:
        block_mgr.dealloc_block(blockset_id, b)
        validate_blockset()

    block_mgr.step_defragment_blockset(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_defrag_cursor(blockset) != NULL and count < k:

        block_mgr.step_defragment_blockset(blockset)

        validate_blockset()

        count += 1

    assert count < k/4
    assert block_mgr.get_blockset_free_list_length(blockset) == 1
