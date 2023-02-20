import math
import random
import sys
import time

from itertools import zip_longest

import pytest

from modules import block_mgr, block_mgr_test_client, lists, pairs, values
import util

blockset_id = 7
blockset = block_mgr.get_blockset(blockset_id)

mgr_blockset_id = block_mgr.block_mgr_blockset_id.value
mgr_blockset = block_mgr.get_blockset(mgr_blockset_id)

NULL = block_mgr.NULL.value

def debug():
    block_mgr.DEBUG.value = True

def init_test():
    pairs.init_pairs()
    block_mgr.init_blockset_manager()
    block_mgr_test_client.init(blockset_id)

def list_allocated_pairs():
    addrs = collect_allocated_pairs()

    print('allocated pairs:')

    for pair in addrs:
        print(f'{format_addr(pair)}: ({format_addr(pairs.get_pair_car(pair))} . {format_addr(pairs.get_pair_cdr(pair))})')

    # print('initial pairs:')

    # for pair in range(0, 80, 8):
    #     print(f'{format_addr(pair)}: ({format_addr(pairs.get_pair_car(pair))} . {format_addr(pairs.get_pair_cdr(pair))})')

def collect_allocated_pairs():
    addrs = []
    free_addrs = set()

    free_pair = pairs.pair_free_list.value
    while free_pair != NULL:
        free_addrs.add(free_pair)
        free_pair = pairs.get_pair_car(free_pair)

    for addr in range(0, pairs.pairs_top.value, pairs.pair_size.value):
        if addr not in free_addrs:
            addrs.append(addr)

    return addrs

def print_all():
    list_allocated_pairs()
    print()
    print_blockset()

def print_blockset(blockset, depth=None):
    print('state:')
    print_block_mgr_state(blockset)
    print()

    if depth is None:
        print('block list:')
        print_block_list(blockset)
        print()

        print('free list:')
        print_free_list(blockset)
        print()

        print('heap:')
        print_heap(blockset)
        print()
    else:
        print('top of heap:')
        print_heap(blockset, depth)
        print()

def validate_blockset(blockset):

    validate_block_list(blockset)
    validate_free_list(blockset)
    validate_heap(blockset)

    pair_count = pairs.pair_count.value

    block_mgr_pair_count = count_blockset_pairs(mgr_blockset)
    blockset_pair_count = 0

    if blockset != mgr_blockset:
        blockset_pair_count = count_blockset_pairs(blockset)

    assert pair_count == block_mgr_pair_count + blockset_pair_count

def validate_block_list(blockset):

    block_count = block_mgr.get_blockset_block_count(blockset)
    block_list = block_mgr.get_blockset_block_list(blockset)

    last = NULL
    addr = block_mgr.get_block_ref_addr(block_list) if block_list != NULL else NULL
    ref = block_list
    turtle = ref
    count = 0
    while ref != NULL:
        if block_mgr.get_block_ref_addr(ref) != addr:
            print(format_addr(ref), format_addr(block_mgr.get_block_ref_addr(ref)), format_addr(addr))
        assert block_mgr.get_block_ref_addr(ref) == addr
        addr += block_mgr.get_block_ref_size(ref)
        last = ref
        ref = pairs.get_pair_cdr(ref)
        count += 1
        if count % 2 == 0:
            turtle = pairs.get_pair_cdr(turtle)
            assert turtle != ref
        assert count <= block_count

    assert count == block_count
    assert block_mgr.get_blockset_end_block_ref(blockset) == last

def validate_free_list(blockset):

    block_list = block_mgr.get_blockset_block_list(blockset)
    free_list = block_mgr.get_blockset_free_list(blockset)
    free_list_length = block_mgr.get_blockset_free_list_length(blockset)

    refs = set()
    ref = block_list
    while ref != NULL:
        refs.add(ref)
        ref = pairs.get_pair_cdr(ref)

    defrag_cursor = block_mgr.get_blockset_defrag_cursor(blockset)
    assert defrag_cursor == NULL or defrag_cursor in refs

    entry = free_list
    last_free_addr = -1
    free_space = 0
    turtle = entry
    count = 0
    while entry != NULL:
        assert pairs.get_pair_car(entry) in refs
        free_addr = block_mgr.get_free_entry_addr(entry)
        free_space += block_mgr.get_free_entry_size(entry)
        assert free_addr  > last_free_addr
        last_free_addr = free_addr
        entry = pairs.get_pair_cdr(entry)
        count += 1
        if count % 2 == 0:
            turtle = pairs.get_pair_cdr(turtle)
            assert turtle != entry

        assert count <= free_list_length

    assert count == free_list_length
    assert free_space == block_mgr.get_blockset_free_space(blockset)

def validate_heap(blockset):

    free_list = block_mgr.get_blockset_free_list(blockset)
    heap = block_mgr.get_blockset_heap(blockset)
    heap_size = block_mgr.get_blockset_heap_size(blockset)

    free_entries = []
    entry = free_list
    while entry != NULL:
        free_entries.append(entry)
        entry = pairs.get_pair_cdr(entry)

    size = 0

    for idx in range(heap_size):
        if idx > 0:
            size = block_mgr.get_heap_block_size(heap, idx)
            parent_idx = block_mgr.calc_parent_idx(idx)
            parent_size = block_mgr.get_heap_block_size(heap, parent_idx)
            assert size <= parent_size

        entry = block_mgr.get_heap_node_entry(heap, idx)

        assert (
            entry in free_entries
            or block_mgr.is_unused_heap_block(heap, idx)
        )

        assert block_mgr.get_heap_block(heap, idx) == block_mgr.get_free_entry_block(entry)

def count_blockset_pairs(blockset):

    block_count = block_mgr.get_blockset_block_count(blockset)
    free_list_length = block_mgr.get_blockset_free_list_length(blockset)

    heap = block_mgr.get_blockset_heap(blockset)
    heap_size = block_mgr.get_blockset_heap_size(blockset)
    unused_free_count = sum(block_mgr.is_unused_heap_block(heap, idx)
                            for idx in range(heap_size))

    # each block ref is 2 pairs (block ref, block)
    # each unused free entry contains a block not in the block list (block ref, block)
    # each free entry is an additional pair over the block ref already counted
    return 3*heap_size + 2*(block_count - free_list_length)

def print_block_mgr_state(blockset):

    heap = block_mgr.get_blockset_heap(blockset)
    inactive_free_memory = block_mgr.get_blockset_inactive_free_memory(blockset)
#    total_size = block_mgr.get_blockset_total_size(blockset)
    free_space = block_mgr.get_blockset_free_space(blockset)
    heap_root_size = 0 if heap == NULL else block_mgr.get_heap_block_size(heap, 0)
    defrag_cursor = block_mgr.get_blockset_defrag_cursor(blockset)

    print("get_blockset_block_count:", block_mgr.get_blockset_block_count(blockset))
    print("get_blockset_block_list:", format_addr(block_mgr.get_blockset_block_list(blockset)))
    print("get_blockset_defrag_cursor:", format_addr(defrag_cursor), '' if defrag_cursor == NULL else f'@ {format_addr(block_mgr.get_block_ref_addr(defrag_cursor))}')
    print("get_blockset_end_block_ref:", format_addr(block_mgr.get_blockset_end_block_ref(blockset)))
    print("get_blockset_heap:", format_addr(heap))
    print("get_blockset_heap_size:", block_mgr.get_blockset_heap_size(blockset))
    print("get_blockset_free_list:", format_addr(block_mgr.get_blockset_free_list(blockset)))
    print("get_blockset_free_list_length:", block_mgr.get_blockset_free_list_length(blockset))
    print("get_blockset_free_space:", free_space)
    print("get_blockset_inactive_free_memory:", inactive_free_memory)

#    print("inactive free space ratio:", 0 if total_size == 0 else inactive_free_memory/total_size)
    print("heap root ratio:", 0 if free_space == 0 else heap_root_size/free_space)

def print_heap(blockset, depth=None):
    heap_size = block_mgr.get_blockset_heap_size(blockset)
    depth = depth or int(math.log2(heap_size or 1))+1
    for s in format_heap_node(block_mgr.get_blockset_heap(blockset), 0, depth):
        print(s)
    print()

def format_addr(addr):
    return 'NULL' if addr == NULL else hex((abs(addr) ^ 0xffffffff) + 1) if addr < 0 else hex(addr)

def format_heap_node(heap, n, depth):

    if n >= block_mgr.get_blockset_heap_size(blockset) or depth == 0:
        return []

    f_l = format_heap_node(heap, block_mgr.calc_left_idx(n), depth-1)
    f_r = format_heap_node(heap, block_mgr.calc_right_idx(n), depth-1)

    width_l = len(f_l[0]) if f_l else 0
    width_r = len(f_r[0]) if f_r else 0

    size = block_mgr.get_heap_block_size(heap, n)
    addr = block_mgr.get_heap_block_addr(heap, n)

    s = f'{n}: {size} @ {format_addr(addr)}'

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

def print_block_list(blockset, start=NULL, end=NULL):

    ref = start if start != NULL else block_mgr.get_blockset_block_list(blockset)

    while ref != end:

        addr = block_mgr.get_block_ref_addr(ref)
        size = block_mgr.get_block_ref_size(ref)

        print(f'{format_addr(ref)}: {format_addr(addr)} [{size}]')

        ref = pairs.get_pair_cdr(ref)

def print_free_list(blockset, start=NULL, end=NULL):

    entry = start if start != NULL else block_mgr.get_blockset_free_list(blockset)

    while entry != end:

        addr = block_mgr.get_block_ref_addr(pairs.get_pair_car(entry))
        size = block_mgr.get_block_ref_size(pairs.get_pair_car(entry))

        print(f'{format_addr(entry)}: {size} @ {format_addr(addr)}')

        entry = pairs.get_pair_cdr(entry)

def test_init_block_mgr():
    pairs.init_pairs()
    block_mgr.init_blockset_manager()

    assert block_mgr.get_blockset_block_count(mgr_blockset) == 2
    assert block_mgr.get_blockset_block_list(mgr_blockset) != NULL
    assert block_mgr.get_blockset_defrag_cursor(mgr_blockset) == NULL
    assert block_mgr.get_blockset_end_block_ref(mgr_blockset) != NULL
    assert block_mgr.get_blockset_heap(mgr_blockset) != NULL
    assert block_mgr.get_blockset_heap_size(mgr_blockset) == 1
    assert block_mgr.get_blockset_free_list(mgr_blockset) != NULL
    assert block_mgr.get_blockset_free_list_length(mgr_blockset) == 1

    validate_blockset(mgr_blockset)

def test_init_blockset():
    init_test()

    assert block_mgr.get_blockset_block_count(blockset) == 0
    assert block_mgr.get_blockset_block_list(blockset) == NULL
    assert block_mgr.get_blockset_defrag_cursor(blockset) == NULL
    assert block_mgr.get_blockset_end_block_ref(blockset) == NULL
    assert block_mgr.get_blockset_heap(blockset) != NULL
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

def test_set_blockset_heap_ref():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_heap(blockset) != NULL
    block_mgr.set_blockset_heap_ref(blockset, NULL)
    assert block_mgr.get_blockset_heap_ref(blockset) == NULL

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

def test_alloc_block():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 48)
    assert block_mgr.get_block_ref_size(b) == 48
    validate_blockset(blockset)

def test_alloc_2_blocks():
    init_test()

    b0 = block_mgr.alloc_block(blockset_id, 1024)
    assert block_mgr.get_block_ref_size(b0) == 1024
    b1 = block_mgr.alloc_block(blockset_id, 1024)
    assert block_mgr.get_block_ref_size(b1) == 1024
    assert block_mgr.get_block_addr(b0) != block_mgr.get_block_addr(b1)
    validate_blockset(blockset)

def test_alloc_64k_block():
    init_test()
    block_mgr.DEBUG.value = 1

    b = block_mgr.alloc_block(blockset_id, 1<<16)
    validate_blockset(blockset)
    assert block_mgr.get_block_ref_size(b) == 1<<16

def test_alloc_128k_block():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 1<<17)
    assert block_mgr.get_block_ref_size(b) == 1<<17
    validate_blockset(blockset)

def test_alloc_128_1k_blocks():
    init_test()

    bs = [
        block_mgr.alloc_block(blockset_id, 1024)
        for i in range(128)
    ]
    assert len(bs) == len(set(block_mgr.get_block_addr(b) for b in bs))
    validate_blockset(blockset)

def test_add_free_block():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 256)
    block_mgr.add_free_block(blockset, b)
    validate_blockset(blockset)

def test_alloc_add_free_64k_block():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.add_free_block(blockset, b)
    validate_blockset(blockset)

def test_alloc_add_free_128k_block():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 1<<17)
    block_mgr.add_free_block(blockset, b)
    validate_blockset(blockset)

def test_alloc_add_free_128_1k_blocks():
    init_test()

    N = 128

    bs = [
        block_mgr.alloc_block(blockset_id, 1024)
        for i in range(N)
    ]

    for b in bs:
        block_mgr.add_free_block(blockset, b)
        validate_blockset(blockset)

def test_alloc_add_free_alloc_64k_block():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.add_free_block(blockset, b)
    b = block_mgr.alloc_block(blockset_id, 1<<16)
    validate_blockset(blockset)

def test_alloc_add_free_alloc_64_1k_blocks():
    init_test()

    N = 1024
    k = 64

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]

    validate_blockset(blockset)

    for b in bs:
        block_mgr.add_free_block(blockset, b)

    validate_blockset(blockset)

    for i in range(k):
        block_mgr.alloc_block(blockset_id, N)

    validate_blockset(blockset)

def test_alloc_add_free_linear_sized_blocks():
    init_test()

    N = 1024
    k = 64

    bs = [
        block_mgr.alloc_block(blockset_id, i*N)
        for i in range(1, k)
    ]

    for b in bs:
        validate_blockset(blockset)
        block_mgr.add_free_block(blockset, b)

    validate_blockset(blockset)

    bs = [
        block_mgr.alloc_block(blockset_id, i*N)
        for i in range(1, k)
    ]

    validate_blockset(blockset)

def test_defrag_empty():
    init_test()

    block_mgr.step_defragment_blockset_free_list(blockset)
    print_blockset(blockset)

    validate_blockset(blockset)

def test_defrag_one_alloc_block():
    init_test()

    block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

def test_defrag_one_small_alloc_one_free_block():
    init_test()

    block_mgr.alloc_block(blockset_id, 48)
    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

def test_defrag_two_free_blocks():
    init_test()

    b = block_mgr.alloc_block(blockset_id, 48)
    block_mgr.add_free_block(blockset, b)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

def test_defrag_two_small_alloc_three_free_blocks():
    init_test()

    b0 = block_mgr.alloc_block(blockset_id, 48)
    b1 = block_mgr.alloc_block(blockset_id, 48)
    b2 = block_mgr.alloc_block(blockset_id, 48)
    b3 = block_mgr.alloc_block(blockset_id, 48)

    block_mgr.add_free_block(blockset, b0)
    block_mgr.add_free_block(blockset, b2)

    validate_blockset(blockset)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

def test_defrag_two_small_alloc_three_free_blocks():
    init_test()

    b0 = block_mgr.alloc_block(blockset_id, 48)
    b1 = block_mgr.alloc_block(blockset_id, 48)
    b2 = block_mgr.alloc_block(blockset_id, 48)
    b3 = block_mgr.alloc_block(blockset_id, 48)

    block_mgr.add_free_block(blockset, b0)
    block_mgr.add_free_block(blockset, b2)

    validate_blockset(blockset)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

def test_defrag_several_add_free_blocks():
    init_test()

    N = 256
    k = 64

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]

    for b in bs:
        block_mgr.add_free_block(blockset, b)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

    count = 0

    while block_mgr.get_blockset_defrag_cursor(blockset) != NULL and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k

def test_defrag_many_1k_blocks():
    init_test()

    N = 1024
    k = 96

    validate_blockset(blockset)

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]

    remaining_blocks = []
    for i, b in enumerate(bs):
        if i % 2:
            block_mgr.add_free_block(blockset, b)
            validate_blockset(blockset)
        else:
            remaining_blocks.append(b)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    last_blocks = []
    for i, b in enumerate(remaining_blocks):
        if i % 2 == 0:
            block_mgr.add_free_block(blockset, b)
            validate_blockset(blockset)
        else:
            last_blocks.append(b)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k/2
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    for b in last_blocks:
        block_mgr.add_free_block(blockset, b)
        validate_blockset(blockset)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k/4
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

def test_relocation():
    init_test()

    N = 1024
    k = 96

    bs = [
        block_mgr.alloc_block(blockset_id, N)
        for i in range(k)
    ]

    for i, b in enumerate(bs):
        block_mgr_test_client.fill(b, i)

    for i, b in enumerate(bs):
        assert block_mgr_test_client.check_fill(b, i)

    assert not block_mgr_test_client.check_fill(bs[0], 1)

    remaining_blocks = []
    for i, b in enumerate(bs):
        if i % 2:
            block_mgr.add_free_block(blockset, b)
            validate_blockset(blockset)
        else:
            remaining_blocks.append(b)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset(blockset)

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    for i, b in enumerate(bs):
        if b in remaining_blocks:
            assert block_mgr_test_client.check_fill(b, i)

@pytest.mark.skip('long, probably should be moved somewhere else')
def test_stochastic():

    init_test()

    # default 0x1000
    block_mgr.set_blockset_relocation_size_limit(blockset, 0x800)

    # This will hold the blocks that have been allocated
    blocks = []

    # This tracks the total bytes allocated in `blocks`
    total_allocated = 0

    # Target 1 MB of allocations
    M = 1_000_000

    # When total_allocated == M, the probability of allocating a block at
    # a step should be 50%. For simplicity, these probabilities will have
    # a linear envelope, starting at 95% at 0 total allocated, dropping
    # to 50% at M, and then falling to 0 by M * 1.25.

    problem_step = 200000000
    log_action_min = problem_step-5

    elapsed_ns = 0
    allocs = 0
    deallocs = 0

    alloc_overhead_ns = 0
    for i in range(1000):
        tic = time.perf_counter_ns()
        block_mgr.stub_alloc_block(blockset, 1)
        toc = time.perf_counter_ns()
        alloc_overhead_ns += toc - tic

    alloc_overhead_ns /= 1000

    dealloc_overhead_ns = 0
    for i in range(1000):
        tic = time.perf_counter_ns()
        block_mgr.stub_dealloc_block(blockset, 1)
        toc = time.perf_counter_ns()
        dealloc_overhead_ns += toc - tic

    dealloc_overhead_ns /= 1000

    def step_action_linear(i):
        r = total_allocated / M

        if r <= 1:
            p = 0.95 * (1 - r) + 0.5 * r
        else:
            p = max(0.5 * (1 - 4*(r - 1)), 0)

        c = random.random() < p

        if i == problem_step or i > log_action_min:
            print('alloc' if c else 'dealloc')

        alloc_block(i) if c else dealloc_block(i)

    # Ensure that this is repeatable
    random.seed(0)

    # average number of 4-byte words in each alloc_block request
    L = 16

    # Word size
    w = 4

    # distribution of alloc_block request sizes
    distribution = util.sample_poisson

    def alloc_block(i):
        nonlocal total_allocated
        nonlocal allocs
        allocs += 1
        size = w * distribution(L)
        if i == problem_step:
            print_blockset(blockset, depth=2)
            block_mgr.DEBUG.value = 1
            print('size:', size)
            block_mgr.provision_blockset_heap(blockset, size)
            print_blockset(blockset, depth=2)
        tic = time.perf_counter_ns()
        b = block_mgr.alloc_block(blockset_id, size)
        toc = time.perf_counter_ns()
        nonlocal elapsed_ns
        elapsed_ns += toc - tic
        blocks.append(b)
        total_allocated += size

    def dealloc_block(i):
        nonlocal blocks
        nonlocal total_allocated
        nonlocal deallocs
        deallocs += 1
        b_i = random.randrange(len(blocks))
        b = blocks[b_i]
        if i == problem_step:
            print(format_addr(b))
        blocks = blocks[:b_i] + blocks[b_i+1:]
        total_allocated -= block_mgr.get_block_ref_size(b)
        if i == problem_step:
            block_mgr.DEBUG.value = 1
            print('pre free')
            print_blockset(blockset, depth=2)
            print_heap(blockset, 2)
            validate_blockset(blockset)
            block_mgr.add_free_block(blockset, b)
            print()
            print('pre clean')
            stdout = sys.stdout
            sys.stdout = open('out1b.log', 'w')
            print_blockset(blockset)
            sys.stdout = stdout
            print_blockset(blockset, depth=2)
            validate_blockset(blockset)
            block_mgr.step_clean_heap(blockset)
            print()
            print('post clean')
            stdout = sys.stdout
            sys.stdout = open('out2b.log', 'w')
            print_blockset(blockset)
            sys.stdout = stdout
            print_blockset(blockset, depth=2)
            validate_blockset(blockset)
            assert False
            # print()
            # print('prepare')
            # print_blockset(depth=2)
            # p, c, n = block_mgr.prepare_defragment_blockset(blockset)
            # print(format_addr(p), format_addr(c), format_addr(n))
            # print_blockset(depth=2)
            # print()
            # print("relevant blocks:")
            # print_block_list(block_mgr.get_blockset_defrag_cursor(blockset), pairs.get_pair_cdr(pairs.get_pair_car(n)))
            # # print_block_list(pairs.get_pair_car(p), pairs.get_pair_cdr(pairs.get_pair_car(n)))
            # print()
            # print("relevant free entries:")
            # print_free_list(p, pairs.get_pair_cdr(n))
            # print()
            # validate_blockset(blockset)
            # # fr = pairs.get_pair_car(c)
            # # rs = pairs.get_pair_cdr(fr)
            # # nfr = pairs.get_pair_car(n)
            # # rl, rsz = block_mgr.scan_relocatable_blocks(blockset, rs, nfr, 0x1000, 0x1000)
            # # print(format_addr(rl), rsz)
            # block_mgr.step_defragment_blockset_free_list(blockset)
        else:
            tic = time.perf_counter_ns()
            block_mgr.dealloc_block(blockset_id, b)
            toc = time.perf_counter_ns()
            nonlocal elapsed_ns
            elapsed_ns += toc - tic

    # Total number of simulation steps
    N = 1_000_000
#    N = 1_827_100

    # Validation interval (in simulation steps)
    I = N

    # Used for narrowing to identify the step that corrupts the blockset
    v_min = 0
    l_min = N
    default_depth = 2

    for i in range(N):
        if i >= l_min:
            print(f'{[i]}')
            print_blockset(blockset, default_depth)
            print
        try:
            step_action_linear(i)
            if i > v_min and (i+1) % I == 0:
                validate_blockset(blockset)
        except:
            # list_allocated_pairs()
            print_blockset(blockset, default_depth)
            print(total_allocated)
            print(i)
            raise

    print_block_mgr_state(blockset)
    print(f'raw allocator time: {elapsed_ns/1_000_000_000:0.4f}')
    adjusted_elapsed_ns = elapsed_ns - allocs * alloc_overhead_ns - deallocs * dealloc_overhead_ns
    print(f'adjusted allocator time: {adjusted_elapsed_ns/1_000_000_000:0.4f}')
    print(f'amortized ns per alloc-dealloc pair:', adjusted_elapsed_ns/(N/2))
    print(alloc_overhead_ns, dealloc_overhead_ns)
    print(allocs, deallocs)
    # print(i)
    # # validate_blockset(blockset)
    # print('done')
    # assert False
