from block_mgr_util import blockset_id, validate_blockset, print_blockset
from modules import block_mgr, block_mgr_test_client, pairs
import util

blockset = block_mgr.get_blockset(blockset_id)

mgr_blockset_id = block_mgr.block_mgr_blockset_id.value
mgr_blockset = block_mgr.get_blockset(mgr_blockset_id)

NULL = block_mgr.NULL.value

def init_test():
    pairs.init_pairs()
    block_mgr.init_blockset_manager()
    block_mgr_test_client.init(blockset_id)

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
    assert block_mgr.get_blockset_immobile_block_size(blockset_id) == 0x2000
    block_mgr.set_blockset_immobile_block_size(blockset_id, 1)
    assert block_mgr.get_blockset_immobile_block_size(blockset_id) == 1

def test_set_blockset_relocation_size_limit():
    block_mgr_test_client.init(blockset_id)
    assert block_mgr.get_blockset_relocation_size_limit(blockset_id) == 0x1000
    block_mgr.set_blockset_relocation_size_limit(blockset_id, 1)
    assert block_mgr.get_blockset_relocation_size_limit(blockset_id) == 1

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

def test_quantize_size():
    for i in range(1, 16):
        assert block_mgr.quantize_size(i) == i

    for i in range(16, 32):
        x = block_mgr.quantize_size(i)
        assert i <= x <= i+1 and x % 2 == 0

    for i in range(32, 64):
        x = block_mgr.quantize_size(i)
        assert i <= x <= i+3 and x % 4 == 0

    for i in range(64, 128):
        x = block_mgr.quantize_size(i)
        assert i <= x <= i+7 and x % 8 == 0

    for i in range(128, 256):
        x = block_mgr.quantize_size(i)
        assert i <= x <= i+15 and x % 16 == 0

    for i in range(256, 512):
        x = block_mgr.quantize_size(i)
        assert i <= x <= i+31 and x % 32 == 0

def test_calc_max_overage():
    for i in range(1, 16):
        assert block_mgr.calc_max_overage(i) == 4

    for i in range(16, 32):
        assert block_mgr.calc_max_overage(i) == 8

    for i in range(32, 64):
        assert block_mgr.calc_max_overage(i) == 16

    for i in range(64, 128):
        assert block_mgr.calc_max_overage(i) == 32

    for i in range(128, 256):
        assert block_mgr.calc_max_overage(i) == 64

    for i in range(256, 512):
        assert block_mgr.calc_max_overage(i) == 128
