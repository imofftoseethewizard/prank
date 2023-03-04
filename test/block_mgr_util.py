import math
import random
import sys
import time

from itertools import zip_longest

import pytest

from modules.debug.block_mgr import *
from modules.debug.block_mgr_test_client import *
from modules.debug.pairs import *

from util import format_addr

blockset_id = 7
blockset = block_mgr.get_blockset(blockset_id)

mgr_blockset_id = block_mgr.block_mgr_blockset_id.value
mgr_blockset = block_mgr.get_blockset(mgr_blockset_id)

NULL = block_mgr.NULL.value

def debug():
    block_mgr.DEBUG.value = True

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
    #list_allocated_pairs()
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

    # pair_count = pairs.pair_count.value

    # block_mgr_pair_count = count_blockset_pairs(mgr_blockset)
    # blockset_pair_count = 0

    # if blockset != mgr_blockset:
    #     blockset_pair_count = count_blockset_pairs(blockset)

    # assert pair_count == block_mgr_pair_count + blockset_pair_count

def validate_block_list(blockset):

    block_count = block_mgr.get_blockset_block_count(blockset)
    block_list = block_mgr.get_blockset_block_list(blockset)

    last = NULL
    addr = block_mgr.get_block_addr(block_list) if block_list != NULL else NULL
    block = block_list
    turtle = block
    count = 0
    while block != NULL:
        if block_mgr.get_block_addr(block) != addr:
            print(format_addr(block), format_addr(block_mgr.get_block_addr(block)), format_addr(addr))
        assert block_mgr.get_block_addr(block) == addr
        addr += block_mgr.get_block_size(block)
        last = block
        block = block_mgr.get_next_block(block)
        count += 1
        if count % 2 == 0:
            turtle = block_mgr.get_next_block(turtle)
            assert turtle != block
        assert count <= block_count

    assert count == block_count
    assert block_mgr.get_blockset_end_block(blockset) == last

def validate_free_list(blockset):

    block_list = block_mgr.get_blockset_block_list(blockset)
    free_list = block_mgr.get_blockset_free_list(blockset)
    free_list_length = block_mgr.get_blockset_free_list_length(blockset)

    blocks = set()
    block = block_list
    while block != NULL:
        blocks.add(block)
        block = block_mgr.get_next_block(block)

    defrag_cursor = block_mgr.get_blockset_defrag_cursor(blockset)
    assert defrag_cursor == NULL or defrag_cursor in blocks

    entry = free_list
    last_free_addr = -1
    free_space = 0
    turtle = entry
    count = 0
    while entry != NULL:
        assert block_mgr.get_free_entry_block(entry) in blocks
        free_addr = block_mgr.get_free_entry_addr(entry)
        free_space += block_mgr.get_free_entry_size(entry)
        assert free_addr  > last_free_addr
        last_free_addr = free_addr
        entry = block_mgr.get_next_free_entry(entry)
        count += 1
        if count % 2 == 0:
            turtle = block_mgr.get_next_free_entry(turtle)
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
        entry = block_mgr.get_next_free_entry(entry)

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

# def count_blockset_pairs(blockset):

#     block_count = block_mgr.get_blockset_block_count(blockset)
#     free_list_length = block_mgr.get_blockset_free_list_length(blockset)

#     heap = block_mgr.get_blockset_heap(blockset)
#     heap_size = block_mgr.get_blockset_heap_size(blockset)
#     unused_free_count = sum(block_mgr.is_unused_heap_block(heap, idx)
#                             for idx in range(heap_size))

#     # each block ref is 2 pairs (block ref, block)
#     # each unused free entry contains a block not in the block list (block ref, block)
#     # each free entry is an additional pair over the block ref already counted
#     return 3*heap_size + 2*(block_count - free_list_length)

def print_block_mgr_state(blockset):

    heap = block_mgr.get_blockset_heap(blockset)
    inactive_free_memory = block_mgr.get_blockset_inactive_free_memory(blockset)
#    total_size = block_mgr.get_blockset_total_size(blockset)
    free_space = block_mgr.get_blockset_free_space(blockset)
    heap_root_size = 0 if heap == NULL else block_mgr.get_heap_block_size(heap, 0)
    defrag_cursor = block_mgr.get_blockset_defrag_cursor(blockset)

    print("get_blockset_block_count:", block_mgr.get_blockset_block_count(blockset))
    print("get_blockset_block_list:", format_addr(block_mgr.get_blockset_block_list(blockset)))
    print("get_blockset_defrag_cursor:", format_addr(defrag_cursor), '' if defrag_cursor == NULL else f'@ {format_addr(block_mgr.get_block_addr(defrag_cursor))}')
    print("get_blockset_end_block:", format_addr(block_mgr.get_blockset_end_block(blockset)))
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

    block = start if start != NULL else block_mgr.get_blockset_block_list(blockset)

    while block != end:

        addr = block_mgr.get_block_addr(block)
        size = block_mgr.get_block_size(block)

        print(f'{format_addr(block)}: {format_addr(addr)} [{size}]')

        block = block_mgr.get_next_block(block)

def print_free_list(blockset, start=NULL, end=NULL):

    entry = start if start != NULL else block_mgr.get_blockset_free_list(blockset)

    while entry != end:

        block = block_mgr.get_free_entry_block(entry)
        addr = block_mgr.get_block_addr(block)
        size = block_mgr.get_block_size(block)

        print(f'{format_addr(entry)}: {size} @ {format_addr(addr)} [{block_mgr.get_free_entry_addr(entry)}]')

        entry = block_mgr.get_next_free_entry(entry)
