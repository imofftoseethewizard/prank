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

def print_blockset(depth=None):
    print('state:')
    print_block_mgr_state()
    print()

    if depth is None:
        print('block list:')
        print_block_list()
        print()

        print('free list:')
        print_free_list()
        print()

        print('heap:')
        print_heap()
        print()
    else:
        print('top of heap:')
        print_heap(depth)
        print()

def validate_blockset():

    validate_block_list()
    validate_free_list()
    validate_heap()

    block_count = block_mgr.get_blockset_block_count(blockset)
    free_list_length = block_mgr.get_blockset_free_list_length(blockset)
    heap_size = block_mgr.get_blockset_heap_size(blockset)
    pair_count = pairs.pair_count.value

    assert pair_count == 6*heap_size + 2*(block_count - free_list_length)

def validate_block_list():

    block_count = block_mgr.get_blockset_block_count(blockset)
    block_list = block_mgr.get_blockset_block_list(blockset)

    last = NULL
    addr = 0
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

def validate_free_list():

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

def validate_heap():

    free_list = block_mgr.get_blockset_free_list(blockset)
    heap = block_mgr.get_blockset_heap(blockset)
    heap_size = block_mgr.get_blockset_heap_size(blockset)
    visited = set()

    free_entries = []
    entry = free_list
    while entry != NULL:
        free_entries.append(entry)
        entry = pairs.get_pair_cdr(entry)

    size = 0

    pending = [(heap, None)]

    while pending:
        node, parent_size = pending.pop()

        if node != NULL:

            assert node not in visited
            visited.add(node)

            size += 1
            assert size <= heap_size

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

            pending.append((block_mgr.get_heap_left(node), node_size))
            pending.append((block_mgr.get_heap_right(node), node_size))

    assert size == heap_size

def calc_heap_max_depth():

    heap = block_mgr.get_blockset_heap(blockset)

    max_depth = 0

    visited = set()
    pending = [(heap, 1)]

    while pending:
        node, depth = pending.pop()

        if node != NULL and node not in visited:
            visited.add(node)

            if depth > max_depth:
                max_depth = depth

            try:
                pending.append((block_mgr.get_heap_left(node), depth+1))
            except:
                print("heap node corrupted:", format_addr(node))

            try:
                pending.append((block_mgr.get_heap_right(node), depth+1))
            except:
                print("heap node corrupted:", format_addr(node))

    return max_depth

def print_block_mgr_state():
    heap = block_mgr.get_blockset_heap(blockset)
    inactive_free_memory = block_mgr.get_blockset_inactive_free_memory(blockset)
    total_size = block_mgr.get_blockset_total_size(blockset)
    free_space = block_mgr.get_blockset_free_space(blockset)
    heap_root_size = 0 if heap == NULL else block_mgr.get_heap_block_size(heap)
    defrag_cursor = block_mgr.get_blockset_defrag_cursor(blockset)

    print("get_blockset_block_count:", block_mgr.get_blockset_block_count(blockset))
    print("get_blockset_block_list:", format_addr(block_mgr.get_blockset_block_list(blockset)))
    print("get_blockset_defrag_cursor:", format_addr(defrag_cursor), '' if defrag_cursor == NULL else f'@ {format_addr(block_mgr.get_block_ref_addr(defrag_cursor))}')
    print("get_blockset_end_block_ref:", format_addr(block_mgr.get_blockset_end_block_ref(blockset)))
    print("get_blockset_heap:", format_addr(heap))
    print("get_blockset_heap_depth:", block_mgr.get_blockset_heap_depth(blockset))
    print("get_blockset_heap_size:", block_mgr.get_blockset_heap_size(blockset))
    print("get_blockset_free_list:", format_addr(block_mgr.get_blockset_free_list(blockset)))
    print("get_blockset_free_list_length:", block_mgr.get_blockset_free_list_length(blockset))
    print("get_blockset_free_space:", free_space)
    print("get_blockset_inactive_free_memory:", inactive_free_memory)

    print("inactive free space ratio:", 0 if total_size == 0 else inactive_free_memory/total_size)
    print("heap root ratio:", 0 if free_space == 0 else heap_root_size/free_space)
    print("should rebuild heap:", block_mgr.should_rebuild_blockset_heap(blockset))
    print("should compact heap:", block_mgr.should_compact_blockset_heap(blockset))
    print("should defrag:", block_mgr.should_defragment_blockset_free_list(blockset))
    print("max heap depth:", calc_heap_max_depth())

def print_heap(depth=None):
    heap_size = block_mgr.get_blockset_heap_size(blockset)
    depth = depth or int(math.log2(heap_size or 1))+1
    for s in format_heap_node(block_mgr.get_blockset_heap(blockset), depth):
        print(s)
    print()

def format_addr(addr):
    return 'NULL' if addr == NULL else hex(addr)

def format_heap_node(n, depth):
    if n == NULL or depth == 0:
        return []

    f_l = format_heap_node(block_mgr.get_heap_left(n), depth-1)
    f_r = format_heap_node(block_mgr.get_heap_right(n), depth-1)

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

def print_block_list(start=NULL, end=NULL):

    ref = start if start != NULL else block_mgr.get_blockset_block_list(blockset)

    while ref != end:

        addr = block_mgr.get_block_ref_addr(ref)
        size = block_mgr.get_block_ref_size(ref)

        print(f'{format_addr(ref)}: {format_addr(addr)} [{size}]')

        ref = pairs.get_pair_cdr(ref)

def print_free_list(start=NULL, end=NULL):

    entry = start if start != NULL else block_mgr.get_blockset_free_list(blockset)

    while entry != end:

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

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

def test_defrag_one_alloc_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.alloc_block(blockset_id, 1<<16)
    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

def test_defrag_one_small_alloc_one_free_block():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.alloc_block(blockset_id, 48)
    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

def test_defrag_two_free_blocks():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b = block_mgr.alloc_block(blockset_id, 48)
    block_mgr.dealloc_block(blockset_id, b)

    block_mgr.step_defragment_blockset_free_list(blockset)

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

    block_mgr.step_defragment_blockset_free_list(blockset)

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

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

    block_mgr.step_defragment_blockset_free_list(blockset)

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

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_defrag_cursor(blockset) != NULL and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

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

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

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

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset()

        count += 1

    assert count < k/2
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    for b in last_blocks:
        block_mgr.dealloc_block(blockset_id, b)
        validate_blockset()

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset()

        count += 1

    assert count < k/4
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

def test_relocation():

    N = 1024
    k = 96

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

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
            block_mgr.dealloc_block(blockset_id, b)
            validate_blockset()
        else:
            remaining_blocks.append(b)

    block_mgr.step_defragment_blockset_free_list(blockset)

    validate_blockset()

    count = 0

    while block_mgr.get_blockset_free_list_length(blockset) > 1 and count < k:

        block_mgr.step_defragment_blockset_free_list(blockset)

        validate_blockset()

        count += 1

    assert count < k
    assert block_mgr.get_blockset_free_list_length(blockset) == 1

    for i, b in enumerate(bs):
        if b in remaining_blocks:
            assert block_mgr_test_client.check_fill(b, i)

def test_coalesce_heap_null():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.coalesce_blockset_heap(blockset)
    validate_blockset()

def test_coalesce_heap_simple_do_nothing():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    block_mgr.alloc_block(blockset_id, 48)
    block_mgr.coalesce_blockset_heap(blockset)
    validate_blockset()

def test_coalesce_heap_simple():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b = block_mgr.alloc_block(blockset_id, (1<<15) + (1<<14))
    block_mgr.dealloc_block(blockset_id, b)

    block_mgr.coalesce_blockset_heap(blockset)
    assert block_mgr.get_blockset_free_list_length(blockset) == 1
    assert block_mgr.get_blockset_block_count(blockset) == 1
    validate_blockset()

def test_coalesce_heap_double():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b0 = block_mgr.alloc_block(blockset_id, 1<<15)
    b1 = block_mgr.alloc_block(blockset_id, 1<<14)
    block_mgr.dealloc_block(blockset_id, b0)
    block_mgr.dealloc_block(blockset_id, b1)

    block_mgr.coalesce_blockset_heap(blockset)
    assert block_mgr.get_blockset_free_list_length(blockset) == 1
    assert block_mgr.get_blockset_block_count(blockset) == 1
    validate_blockset()

def test_coalesce_heap_alloc_block_at_end():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b0 = block_mgr.alloc_block(blockset_id, 1<<15)
    b1 = block_mgr.alloc_block(blockset_id, 1<<14)
    b2 = block_mgr.alloc_block(blockset_id, 1<<13)
    block_mgr.dealloc_block(blockset_id, b0)
    block_mgr.dealloc_block(blockset_id, b1)

    block_mgr.coalesce_blockset_heap(blockset)
    assert block_mgr.get_blockset_free_list_length(blockset) == 2
    assert block_mgr.get_blockset_block_count(blockset) == 3
    validate_blockset()

def test_compact_heap_simple():
    # set up needs to have three free blocks, and the largest
    # free block needs to have at least one allocated block after
    # it that is small enough to fit in the largest of the free blocks

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    # this will be the largest free block
    b0 = block_mgr.alloc_block(blockset_id, 1<<15)

    # this is the block that will be moved
    b1 = block_mgr.alloc_block(blockset_id, 256)
    block_mgr_test_client.fill(b1, 17)

    # this block won't move
    b2 = block_mgr.alloc_block(blockset_id, 1<<14)

    # this will be the third free block
    b3 = block_mgr.alloc_block(blockset_id, 128)

    # this block separates the b3 from the remaining free space
    b4 = block_mgr.alloc_block(blockset_id, 128)

    # the space occupied by b0 will not be the top of the heap
    block_mgr.dealloc_block(blockset_id, b0)

    # this creates a third free block, a requirement of the compaction algo
    block_mgr.dealloc_block(blockset_id, b3)

    # this should move b1 to the end of the page, the top
    # of the 2nd largest free block
    block_mgr.step_compact_blockset_heap(blockset)

    validate_blockset()

    root = block_mgr.get_blockset_heap(blockset)
    assert block_mgr.get_heap_block_size(root) == (1<<15) + 256

def test_compact_heap_extended():
    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    b0 = block_mgr.alloc_block(blockset_id, 1<<15)
    b1 = block_mgr.alloc_block(blockset_id, 256)
    b2 = block_mgr.alloc_block(blockset_id, 1280)
    b3 = block_mgr.alloc_block(blockset_id, 512)
    b4 = block_mgr.alloc_block(blockset_id, 4096)
    b5 = block_mgr.alloc_block(blockset_id, 1024)
    b6 = block_mgr.alloc_block(blockset_id, 256)
    b7 = block_mgr.alloc_block(blockset_id, 2048)
    b8 = block_mgr.alloc_block(blockset_id, 1<<14)
    b9 = block_mgr.alloc_block(blockset_id, 1<<12)
    b9 = block_mgr.alloc_block(blockset_id, 1<<11)

    block_mgr.dealloc_block(blockset_id, b0)
    block_mgr.dealloc_block(blockset_id, b5)
    block_mgr.dealloc_block(blockset_id, b7)

    block_mgr.step_compact_blockset_heap(blockset)

    validate_blockset()

    root = block_mgr.get_blockset_heap(blockset)
    assert block_mgr.get_heap_block_size(root) == (1<<15) + 2048

def test_stochastic():

    pairs.init_pairs()
    block_mgr_test_client.init(blockset_id)

    denom = 1 << block_mgr.blockset_coefficient_log2_denominator.value

    # If the ideal heap depth is less than 3/4 the actual heap depth, rebuild the heap
    # block_mgr.set_blockset_depth_ratio_coefficient(blockset, int(0.75 * denom))
    block_mgr.set_blockset_depth_ratio_coefficient(blockset, int(0.8 * denom))

    # If less than 2/3 of the heap is used, then rebuild the heap.
    block_mgr.set_blockset_unused_ratio_coefficient(blockset, int(0.90 * denom))

    # If the root block is less than 1/4 of the total free space, then compact
    # the heap at each step.
    block_mgr.set_blockset_heap_ratio_coefficient(blockset, int(1.0 * denom))

    # Inactive free memory is the space consumed by non-root free blocks plus
    # the pairs required to represent them. If the inactive free space is more
    # than 10% of the total storage, then defragment the free list.
    orig_inactive_ratio = block_mgr.get_blockset_inactive_ratio_coefficient(blockset)
    block_mgr.set_blockset_inactive_ratio_coefficient(blockset, int(0 * denom))

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

    problem_step = 66_912_000
    log_action_min = problem_step - 5

    elapsed_ns = 0
    allocs = 0
    deallocs = 0

    alloc_overhead_ns = 0
    for i in range(1000):
        block_mgr.stub_alloc_block(blockset, 1)
        tic = time.perf_counter_ns()
        block_mgr.stub_alloc_block(blockset, 1)
        toc = time.perf_counter_ns()
        alloc_overhead_ns += toc - tic

    alloc_overhead_ns /= 1000

    dealloc_overhead_ns = 0
    for i in range(1000):
        block_mgr.stub_dealloc_block(blockset, 1)
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
            print_blockset(depth=2)
            block_mgr.DEBUG.value = 1
            print('size:', size)
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
            print_blockset(depth=2)
            print_heap(2)
            validate_blockset()
            block_mgr.add_free_block(blockset, b)
            print()
            print('pre compact')
            stdout = sys.stdout
            sys.stdout = open('out1b.log', 'w')
            print_blockset()
            sys.stdout = stdout
            print_blockset(depth=2)
            validate_blockset()
            block_mgr.step_compact_blockset_heap(blockset)
            print()
            print('post compact')
            stdout = sys.stdout
            sys.stdout = open('out2b.log', 'w')
            print_blockset()
            sys.stdout = stdout
            print_blockset(depth=2)
            validate_blockset()
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
            # validate_blockset()
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
            print_blockset(default_depth)
            print
        try:
            step_action_linear(i)
            if i > v_min and (i+1) % I == 0:
                validate_blockset()
        except:
            print_blockset(default_depth)
            print(total_allocated)
            print(i)
            raise

    print_block_mgr_state()
    print(f'raw allocator time: {elapsed_ns/1_000_000_000:0.4f}')
    adjusted_elapsed_ns = elapsed_ns - allocs * alloc_overhead_ns - deallocs * dealloc_overhead_ns
    print(f'adjusted allocator time: {adjusted_elapsed_ns/1_000_000_000:0.4f}')
    print(f'amortized ns per alloc-dealloc pair:', adjusted_elapsed_ns/(N/2))
    print(alloc_overhead_ns, dealloc_overhead_ns)
    print(allocs, deallocs)
    # print(i)
    # # validate_blockset()
    # print('done')
    # assert False
