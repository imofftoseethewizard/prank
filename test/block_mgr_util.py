import math
import random
import sys
import time

from itertools import zip_longest

import pytest

from modules.debug.block_mgr import *
from modules.debug.block_mgr_test_client import *
from modules.debug.lists import *
from modules.debug.pairs import *

from util import format_addr

blockset_id = 3
blockset = block_mgr.get_blockset(blockset_id)

NULL = block_mgr.NULL.value

refs_base = block_mgr.refs_top.value

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
    list_allocated_pairs()
    print()
    print_blockset()

def print_blockset(blockset, depth=None):
    print('state:')
    print_block_mgr_state(blockset)
    print_free_lists(blockset)
    print()

    if depth is None:
        print('block list:')
        print_block_list(blockset)
        print()

def validate_blockset(blockset):
    validate_block_refs(blockset)
    validate_block_list(blockset)
    validate_free_lists(blockset)

def validate_block_refs(blockset):
    provisioned_refs = (block_mgr.refs_top.value - refs_base)/16

    assert provisioned_refs == block_mgr.ref_count.value + count_free_refs()

    block_count = block_mgr.get_blockset_block_count(blockset)
    unused_count = block_mgr.get_blockset_unused_count(blockset)

    assert block_count + unused_count == block_mgr.ref_count.value

def validate_block_list(blockset):

    block_count = block_mgr.get_blockset_block_count(blockset)
    block_list = block_mgr.get_blockset_block_list(blockset)

    last = NULL
    addr = block_mgr.get_block_addr(block_list) if block_list != NULL else NULL
    block = block_list
    turtle = block
    count = 0
    total_size = 0
    while block != NULL:
        assert block_mgr.get_previous_block(block) == last
        if block_mgr.get_block_addr(block) != addr:
            print(format_addr(block), format_addr(block_mgr.get_block_addr(block)), format_addr(addr))
        assert block_mgr.get_block_addr(block) == addr
        size = block_mgr.get_block_size(block)
        assert size > 0
        addr += size
        total_size += size
        last = block
        block = block_mgr.get_next_block(block)
        count += 1
        if count % 2 == 0:
            turtle = block_mgr.get_next_block(turtle)
            assert turtle != block
        assert count <= block_count

    # free_space = block_mgr.get_blockset_free_space(blockset)
    # print(total_size-free_space, free_space, total_size, (total_size-free_space)/count)
    assert count == block_count
    assert block_mgr.get_blockset_end_block(blockset) == last

def validate_free_lists(blockset):

    free_count = block_mgr.get_blockset_free_count(blockset)
    unused_count = block_mgr.get_blockset_unused_count(blockset)

    assert free_count + unused_count == pairs.pair_count.value

    assert count_free_blocks(blockset) == free_count
    assert count_fragments(blockset) == block_mgr.get_blockset_fragment_count(blockset)

    for idx, free_list in enumerate(free_lists(blockset)):
        if free_list is not NULL:
            min_size = free_list_idx_to_size(idx)
            for block in free_list_blocks(free_list):
                size = block_mgr.get_block_size(block)
                assert size >= min_size


def print_block_mgr_state(blockset):

    free_space = block_mgr.get_blockset_free_space(blockset)

    print("get_blockset_block_count:", block_mgr.get_blockset_block_count(blockset))
    print("get_blockset_fragment_count:", block_mgr.get_blockset_fragment_count(blockset))
    print("get_blockset_free_count:", block_mgr.get_blockset_free_count(blockset))
    print("get_blockset_unused_count:", block_mgr.get_blockset_unused_count(blockset))
    print("get_blockset_block_list:", format_addr(block_mgr.get_blockset_block_list(blockset)))
    print("get_blockset_end_block:", format_addr(block_mgr.get_blockset_end_block(blockset)))
    print("get_blockset_free_space:", free_space)
    print("get_blockset_free_lists_base:", format_addr(block_mgr.get_blockset_free_lists_base(blockset)))
    print("get_blockset_free_lists_top:", format_addr(block_mgr.get_blockset_free_lists_top(blockset)))
    print("free block count:", count_free_blocks(blockset))

def print_block_list(blockset, start=NULL, end=NULL):

    block = start if start != NULL else block_mgr.get_blockset_block_list(blockset)

    while block != end:

        addr = block_mgr.get_block_addr(block)
        size = block_mgr.get_block_size(block)

        print(f'{format_addr(block)}: {format_addr(addr)} [{size}]')

        block = block_mgr.get_next_block(block)

def print_free_lists(blockset):

    for idx, free_list in enumerate(free_lists(blockset)):
        if free_list is not NULL:
            print(idx, format_addr(free_list_idx_to_size(idx)), format_addr(free_list))
            for block in free_list_blocks(free_list):
                addr = block_mgr.get_block_addr(block)
                size = block_mgr.get_block_size(block)
                print(f'  {format_addr(block)}: {size} @ {format_addr(addr)}')

def free_lists(blockset):

    free_list = block_mgr.get_blockset_free_lists_base(blockset)
    free_list_top = block_mgr.get_blockset_free_lists_top(blockset)
    while free_list < free_list_top:
        yield block_mgr.get_free_list_head(free_list)
        free_list += 4

def free_list_blocks(free_list):

    while free_list != NULL:
        block = pairs.get_pair_car(free_list)
        yield block
        free_list = pairs.get_pair_cdr(free_list)

def free_blocks(free_list):

    for block in free_list_blocks(free_list):
        if not block_mgr.is_unused_block(block):
            yield block

def fragments(free_list):

    for block in free_list_blocks(free_list):
        if not block_mgr.is_unused_block(block):
            if block_mgr.get_block_size(block) < block_mgr.fragment_size.value:
                yield block

def count_free_blocks(blockset):

    return sum(len(list(free_blocks(free_list)))
               for free_list in free_lists(blockset))

def count_unused_blocks(blockset):

    return sum(len(list(unused_blocks(free_list)))
               for free_list in free_lists(blockset))

def count_free_refs():

    count = 0
    head = block_mgr.ref_free_list.value

    while head != NULL:
        head = block_mgr.get_block_addr(head)
        count += 1

    return count

def fragment_lists(blockset):

    free_list = block_mgr.get_blockset_free_lists_base(blockset)
    free_list_top = block_mgr.get_blockset_free_lists_top(blockset)
    count = 0
    while free_list < free_list_top and count < block_mgr.fragment_size.value:
        yield block_mgr.get_free_list_head(free_list)
        free_list += 4
        count += 1

def count_fragments(blockset):

    return sum(len(list(fragments(free_list)))
               for free_list in fragment_lists(blockset))

def free_list_offset_to_size(offset):
    return free_idx_list_idx_to_size(offset >> 2)

def free_list_idx_to_size(idx):
    shift = block_mgr.alloc_precision_bits.value - 1
    mask = (1 << shift) - 1
    rank = (idx >> shift) - 1
    return ((0 if rank < 0 else 1) << (rank + shift)) + ((idx & mask) << max(0, rank))

def summarize_free_list(blockset):

    for idx, free_list in enumerate(free_lists(blockset)):
        if free_list is not NULL:
            bs = list(free_blocks(free_list))
            free_count = len(bs)
            unused_count = get_list_length(free_list) - free_count
            sizes = set(
                get_block_size(b)
                for b in bs
            )
            print(f'{idx} {free_list_idx_to_size(idx)}: {free_count} {unused_count}* -- {list(sorted(sizes))}')
