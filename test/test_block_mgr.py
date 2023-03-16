import pytest

from block_mgr_util import (
    blockset_id, validate_blockset, print_blockset, print_block_mgr_state, print_free_lists,
    format_addr, count_free_blocks, summarize_free_list
)
from modules.debug.block_mgr import *
from modules.debug.block_mgr_test_client import *
from modules.debug.pairs import *

import util

blockset = get_blockset(blockset_id)

NULL = NULL.value

def init_test():
    init_pairs()
    init_blockset_manager()
    init(blockset_id)

def test_init_block_mgr():
    init_pairs()
    init_blockset_manager()

def test_init_blockset():
    init_test()

    assert get_blockset_block_count(blockset) == 0
    assert get_blockset_block_list(blockset) == NULL
    assert get_blockset_end_block(blockset) == NULL

def test_get_blockset_id():
    assert get_blockset_id(blockset) == blockset_id
    assert get_blockset_id(get_blockset(1)) == 1
    assert get_blockset_id(get_blockset(2)) == 2
    assert get_blockset_id(get_blockset(3)) == 3

def test_set_blockset_block_count():
    init(blockset_id)
    assert get_blockset_block_count(blockset) == 0
    set_blockset_block_count(blockset, 1)
    assert get_blockset_block_count(blockset) == 1

def test_set_blockset_block_list():
    init(blockset_id)
    assert get_blockset_block_list(blockset) == NULL
    set_blockset_block_list(blockset, 1)
    assert get_blockset_block_list(blockset) == 1

def test_set_blockset_end_block():
    init(blockset_id)
    assert get_blockset_end_block(blockset) == NULL
    set_blockset_end_block(blockset, 1)
    assert get_blockset_end_block(blockset) == 1

def test_set_blockset_relocation_size_limit():
    init(blockset_id)
    set_blockset_relocation_size_limit(blockset_id, 1)
    assert get_blockset_relocation_size_limit(blockset_id) == 1
    set_blockset_relocation_size_limit(blockset_id, 2)
    assert get_blockset_relocation_size_limit(blockset_id) == 2

def test_decr_blockset_block_count():
    init(blockset_id)
    set_blockset_block_count(blockset, 1)
    decr_blockset_block_count(blockset)
    assert get_blockset_block_count(blockset) == 0

def test_incr_blockset_block_count():
    init(blockset_id)
    set_blockset_block_count(blockset, 1)
    incr_blockset_block_count(blockset)
    assert get_blockset_block_count(blockset) == 2

def test_make_block():
    b = make_ref(64, 4)
    assert get_block_addr(b) == 64
    assert get_block_size(b) == 4

def test_get_next_block_addr():
    b = make_ref(64, 4)
    assert get_next_block_addr(b) == 68

def test_set_block_addr():
    b = make_ref(64, 4)
    set_block_addr(b, 72)
    assert get_block_addr(b) == 72

def test_set_block_size():
    b = make_ref(64, 4)
    set_block_size(b, 8)
    assert get_block_size(b) == 8

def test_quantize_size():

    block_mgr.alloc_precision_bits.value = 3

    for i in range(1, 8):
        assert quantize_size(i) == i

    for i in range(8, 16):
        x = quantize_size(i)
        assert i <= x <= i+1 and x % 2 == 0

    for i in range(16, 32):
        x = quantize_size(i)
        assert i <= x <= i+3 and x % 4 == 0

    for i in range(32, 64):
        x = quantize_size(i)
        assert i <= x <= i+7 and x % 8 == 0

    for i in range(64, 128):
        x = quantize_size(i)
        assert i <= x <= i+15 and x % 16 == 0

    for i in range(128, 256):
        x = quantize_size(i)
        assert i <= x <= i+31 and x % 32 == 0

    for i in range(256, 512):
        x = quantize_size(i)
        assert i <= x <= i+63 and x % 64 == 0

    block_mgr.alloc_precision_bits.value = 4

    for i in range(1, 16):
        assert quantize_size(i) == i

    for i in range(16, 32):
        x = quantize_size(i)
        assert i <= x <= i+1 and x % 2 == 0

    for i in range(32, 64):
        x = quantize_size(i)
        assert i <= x <= i+3 and x % 4 == 0

    for i in range(64, 128):
        x = quantize_size(i)
        assert i <= x <= i+7 and x % 8 == 0

    for i in range(128, 256):
        x = quantize_size(i)
        assert i <= x <= i+15 and x % 16 == 0

    for i in range(256, 512):
        x = quantize_size(i)
        assert i <= x <= i+31 and x % 32 == 0

def test_calc_free_list_offset():

    block_mgr.alloc_precision_bits.value = 3

    for i in range(1, 8):
        assert 4*i == calc_free_list_offset(i)

    for i in range(8, 16):
        assert 4*(4+(i>>1)) == calc_free_list_offset(i)

    for i in range(16, 32):
        assert 4*(8+(i>>2)) == calc_free_list_offset(i)

    block_mgr.alloc_precision_bits.value = 4

    for i in range(1, 16):
        assert 4*i == calc_free_list_offset(i)

    for i in range(16, 32):
        assert 4*(8+(i>>1)) == calc_free_list_offset(i)

    for i in range(32, 64):
        assert 4*(16+(i>>2)) == calc_free_list_offset(i)

def test_pop_free_block_initial():
    init_test()

    free_list = block_mgr.get_blockset_free_lists_base(blockset)
    free_list_top = block_mgr.get_blockset_free_lists_top(blockset)
    while free_list < free_list_top:
        assert block_mgr.pop_free_block(blockset, free_list) == NULL
        free_list += 4

def test_select_blockset_free_list_initial():
    init_test()

    free_list = block_mgr.select_blockset_free_list(blockset, 48)

    assert free_list % 4 == 0
    assert (
        block_mgr.get_blockset_free_lists_base(blockset)
        <= free_list
        < block_mgr.get_blockset_free_lists_top(blockset)
    )
    assert block_mgr.get_free_list_head(free_list) == NULL

def test_alloc_block():
    init_test()

    b = alloc_block(blockset_id, 48)
    assert get_block_size(b) == 48
    print_blockset(blockset)
    validate_blockset(blockset)

def test_alloc_block_fragment():
    init_test()

    b = alloc_block(blockset_id, 4)
    assert get_block_size(b) == 4
    print_blockset(blockset)
    validate_blockset(blockset)

def test_alloc_2_blocks():
    init_test()

    b0 = alloc_block(blockset_id, 1024)
    assert get_block_size(b0) == 1024
    b1 = alloc_block(blockset_id, 1024)
    assert get_block_size(b1) == 1024
    assert get_block_addr(b0) != get_block_addr(b1)
    validate_blockset(blockset)

def test_alloc_64k_block():
    init_test()

    b = alloc_block(blockset_id, 1<<16)
    validate_blockset(blockset)
    assert get_block_size(b) == 1<<16

def test_alloc_128k_block():
    init_test()

    b = alloc_block(blockset_id, 1<<17)
    assert get_block_size(b) == 1<<17
    validate_blockset(blockset)

def test_alloc_128_1k_blocks():
    init_test()

    bs = [
        alloc_block(blockset_id, 1024)
        for i in range(128)
    ]
    assert len(bs) == len(set(get_block_addr(b) for b in bs))
    validate_blockset(blockset)

def test_add_free_block():
    init_test()

    b = alloc_block(blockset_id, 256)
    add_free_block(blockset, b)
    validate_blockset(blockset)

def test_alloc_add_free_64k_block():
    init_test()

    b = alloc_block(blockset_id, 1<<16)
    add_free_block(blockset, b)
    validate_blockset(blockset)

def test_alloc_add_free_128k_block():
    init_test()

    b = alloc_block(blockset_id, 1<<17)
    add_free_block(blockset, b)
    validate_blockset(blockset)

def test_alloc_add_free_128_1k_blocks():
    init_test()

    N = 128

    bs = [
        alloc_block(blockset_id, 1024)
        for i in range(N)
    ]

    for b in bs:
        add_free_block(blockset, b)
        validate_blockset(blockset)

def test_alloc_add_free_alloc_64k_block():
    init_test()

    b = alloc_block(blockset_id, 1<<16)
    add_free_block(blockset, b)
    b = alloc_block(blockset_id, 1<<16)
    validate_blockset(blockset)

def test_alloc_add_free_alloc_64_1k_blocks():
    init_test()

    N = 1024
    k = 64

    bs = [
        alloc_block(blockset_id, N)
        for i in range(k)
    ]

    validate_blockset(blockset)

    for b in bs:
        add_free_block(blockset, b)

    validate_blockset(blockset)

    for i in range(k):
        alloc_block(blockset_id, N)

    validate_blockset(blockset)

def test_alloc_add_free_linear_sized_blocks():
    init_test()

    N = 1024
    k = 64

    bs = [
        alloc_block(blockset_id, i*N)
        for i in range(1, k)
    ]

    for b in bs:
        validate_blockset(blockset)
        add_free_block(blockset, b)

    validate_blockset(blockset)

    bs = [
        alloc_block(blockset_id, i*N)
        for i in range(1, k)
    ]

    validate_blockset(blockset)

def test_defrag_empty():
    init_test()

    step_defragment_blockset(blockset)

    validate_blockset(blockset)

def test_defrag_one_alloc_block():
    init_test()

    alloc_block(blockset_id, 1<<16)
    step_defragment_blockset(blockset)

    validate_blockset(blockset)

def test_defrag_one_small_alloc_one_free_block():
    init_test()

    alloc_block(blockset_id, 48)
    step_defragment_blockset(blockset)

    validate_blockset(blockset)

def test_defrag_two_free_blocks():
    init_test()

    b = alloc_block(blockset_id, 48)
    add_free_block(blockset, b)

    step_defragment_blockset(blockset)

    validate_blockset(blockset)

def test_defrag():
    init_test()

    for rank in range(16, 0, -1):
        bs = [
            alloc_block(blockset_id, 1<<rank)
            for n in range(0, 1<<(16-rank))
        ]

        for i, b in enumerate(bs):
            if False and rank == 4:
                print_block_mgr_state(blockset)
                summarize_free_list(blockset)
            dealloc_block(blockset_id, b)
            if False and rank == 4:
                print_block_mgr_state(blockset)
                summarize_free_list(blockset)
                print(i)
                validate_blockset(blockset)

    print_block_mgr_state(blockset)
    summarize_free_list(blockset)

@pytest.mark.skip('no defrag')
def test_defrag_many_1k_blocks():
    init_test()

    N = 1024
    k = 96

    validate_blockset(blockset)

    bs = [
        alloc_block(blockset_id, N)
        for i in range(k)
    ]

    remaining_blocks = []
    for i, b in enumerate(bs):
        if i % 2:
            add_free_block(blockset, b)
            validate_blockset(blockset)
        else:
            remaining_blocks.append(b)

    step_defragment_blockset(blockset)

    validate_blockset(blockset)

    count = 0

    while count_free_blocks(blockset) > 1 and count < k:

        step_defragment_blockset(blockset)

        validate_blockset(blockset)

        count += 1

    print_blockset(blockset)
    assert count < k
    assert count_free_blocks(blockset) == 1

    last_blocks = []
    for i, b in enumerate(remaining_blocks):
        if i % 2 == 0:
            add_free_block(blockset, b)
            validate_blockset(blockset)
        else:
            last_blocks.append(b)

    step_defragment_blockset(blockset)

    validate_blockset(blockset)

    count = 0

    while count_free_blocks(blockset) > 1 and count < k:

        step_defragment_blockset(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k/2
    assert count_free_blocks(blockset) == 1

    for b in last_blocks:
        add_free_block(blockset, b)
        validate_blockset(blockset)

    step_defragment_blockset(blockset)

    validate_blockset(blockset)

    count = 0

    while count_free_blocks(blockset) > 1 and count < k:

        step_defragment_blockset(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k/4
    assert count_free_blocks(blockset) == 1

@pytest.mark.skip('no defrag')
def test_relocation():
    init_test()

    N = 1024
    k = 96

    bs = [
        alloc_block(blockset_id, N)
        for i in range(k)
    ]

    for i, b in enumerate(bs):
        fill(b, i)

    for i, b in enumerate(bs):
        assert check_fill(b, i)

    assert not check_fill(bs[0], 1)

    remaining_blocks = []
    for i, b in enumerate(bs):
        if i % 2:
            add_free_block(blockset, b)
            validate_blockset(blockset)
        else:
            remaining_blocks.append(b)

    step_defragment_blockset(blockset)

    validate_blockset(blockset)

    count = 0

    while count_free_blocks(blockset) > 1 and count < k:

        step_defragment_blockset(blockset)

        validate_blockset(blockset)

        count += 1

    assert count < k
    assert count_free_blocks(blockset) == 1

    for i, b in enumerate(bs):
        if b in remaining_blocks:
            assert check_fill(b, i)
