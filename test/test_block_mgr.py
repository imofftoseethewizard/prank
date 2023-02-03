from modules import block_mgr, block_mgr_test_client, lists, pairs, values

def test_init_block_mgr():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_block_count(0) == 0
    assert block_mgr.get_blockset_block_list(0) == block_mgr.NULL.value
    assert block_mgr.get_blockset_defrag_cursor(0) == block_mgr.NULL.value
    assert block_mgr.get_blockset_end_block_ref(0) == block_mgr.NULL.value
    assert block_mgr.get_blockset_heap(0) == block_mgr.NULL.value
    assert block_mgr.get_blockset_heap_size(0) == 0
    assert block_mgr.get_blockset_free_list(0) == block_mgr.NULL.value
    assert block_mgr.get_blockset_free_list_length(0) == 0

def test_get_blockset_id():
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(0)) == 0
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(1)) == 1
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(2)) == 2
    assert block_mgr.get_blockset_id(block_mgr.get_blockset(3)) == 3

def test_set_blockset_block_count():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_block_count(0) == 0
    block_mgr.set_blockset_block_count(0, 1)
    assert block_mgr.get_blockset_block_count(0) == 1

def test_set_blockset_block_list():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_block_list(0) == block_mgr.NULL.value
    block_mgr.set_blockset_block_list(0, 1)
    assert block_mgr.get_blockset_block_list(0) == 1

def test_set_blockset_defrag_cursor():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_defrag_cursor(0) == block_mgr.NULL.value
    block_mgr.set_blockset_defrag_cursor(0, 1)
    assert block_mgr.get_blockset_defrag_cursor(0) == 1

def test_set_blockset_end_block_ref():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_end_block_ref(0) == block_mgr.NULL.value
    block_mgr.set_blockset_end_block_ref(0, 1)
    assert block_mgr.get_blockset_end_block_ref(0) == 1

def test_set_blockset_heap():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_heap(0) == block_mgr.NULL.value
    block_mgr.set_blockset_heap(0, 1)
    assert block_mgr.get_blockset_heap(0) == 1

def test_set_blockset_heap_size():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_heap_size(0) == 0
    block_mgr.set_blockset_heap_size(0, 1)
    assert block_mgr.get_blockset_heap_size(0) == 1

def test_set_blockset_free_list():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_free_list(0) == block_mgr.NULL.value
    block_mgr.set_blockset_free_list(0, 1)
    assert block_mgr.get_blockset_free_list(0) == 1

def test_set_blockset_free_list_length():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_free_list_length(0) == 0
    block_mgr.set_blockset_free_list_length(0, 1)
    assert block_mgr.get_blockset_free_list_length(0) == 1

def test_set_blockset_immobile_block_size():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_immobile_block_size(0) == 0x2000
    block_mgr.set_blockset_immobile_block_size(0, 1)
    assert block_mgr.get_blockset_immobile_block_size(0) == 1

def test_set_blockset_relocation_size_limit():
    block_mgr_test_client.init()
    assert block_mgr.get_blockset_relocation_size_limit(0) == 0x1000
    block_mgr.set_blockset_relocation_size_limit(0, 1)
    assert block_mgr.get_blockset_relocation_size_limit(0) == 1

def test_decr_blockset_block_count():
    block_mgr_test_client.init()
    block_mgr.set_blockset_block_count(0, 1)
    block_mgr.decr_blockset_block_count(0)
    assert block_mgr.get_blockset_block_count(0) == 0

def test_decr_blockset_heap_size():
    block_mgr_test_client.init()
    block_mgr.set_blockset_heap_size(0, 1)
    block_mgr.decr_blockset_heap_size(0)
    assert block_mgr.get_blockset_heap_size(0) == 0

def test_decr_blockset_free_list_length():
    block_mgr_test_client.init()
    block_mgr.set_blockset_free_list_length(0, 1)
    block_mgr.decr_blockset_free_list_length(0)
    assert block_mgr.get_blockset_free_list_length(0) == 0

def test_incr_blockset_block_count():
    block_mgr_test_client.init()
    block_mgr.set_blockset_block_count(0, 1)
    block_mgr.incr_blockset_block_count(0)
    assert block_mgr.get_blockset_block_count(0) == 2

def test_incr_blockset_heap_size():
    block_mgr_test_client.init()
    block_mgr.set_blockset_heap_size(0, 1)
    block_mgr.incr_blockset_heap_size(0)
    assert block_mgr.get_blockset_heap_size(0) == 2

def test_incr_blockset_free_list_length():
    block_mgr_test_client.init()
    block_mgr.set_blockset_free_list_length(0, 1)
    block_mgr.incr_blockset_free_list_length(0)
    assert block_mgr.get_blockset_free_list_length(0) == 2

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
    r = pairs.make_pair(block_mgr.make_block(64, 4), block_mgr.NULL.value)
    assert block_mgr.get_block_ref_addr(r) == 64
    assert block_mgr.get_block_ref_size(r) == 4

def test_set_block_ref_addr():
    r = pairs.make_pair(block_mgr.make_block(64, 4), block_mgr.NULL.value)
    block_mgr.set_block_ref_addr(r, 72)
    assert block_mgr.get_block_ref_addr(r) == 72

def test_set_block_ref_size():
    r = pairs.make_pair(block_mgr.make_block(64, 4), block_mgr.NULL.value)
    block_mgr.set_block_ref_size(r, 8)
    assert block_mgr.get_block_ref_size(r) == 8

def test_block_ref_accessors():
    e = pairs.make_pair(pairs.make_pair(block_mgr.make_block(64, 4), block_mgr.NULL.value), block_mgr.NULL.value)
    assert block_mgr.get_free_entry_addr(e) == 64
    assert block_mgr.get_free_entry_size(e) == 4

def test_set_free_entry_addr():
    e = pairs.make_pair(pairs.make_pair(block_mgr.make_block(64, 4), block_mgr.NULL.value), block_mgr.NULL.value)
    block_mgr.set_free_entry_addr(e, 72)
    assert block_mgr.get_free_entry_addr(e) == 72

def test_make_heap_node():
    b = block_mgr.make_block(64, 4)
    r = pairs.make_pair(b, block_mgr.NULL.value)
    e = pairs.make_pair(r, block_mgr.NULL.value)
    n = block_mgr.make_heap_node(e)
    assert block_mgr.get_heap_block(n) == b
    assert block_mgr.get_heap_block_addr(n) == 64
    assert block_mgr.get_heap_block_size(n) == 4
    assert block_mgr.get_heap_node_entry(n) == e
    assert block_mgr.get_heap_left(n) == block_mgr.NULL.value
    assert block_mgr.get_heap_right(n) == block_mgr.NULL.value
