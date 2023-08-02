from util import to_int

from modules.debug.pairs import *
from modules.debug import block_mgr, numbers

NULL = NULL.value

# Global state?! Yes.  The wasm modules have global state, and this
# parallels that fact.  In fact, passing these around as parameters
# and return values would be a misrepresentation of the underlying
# properties of this system.

# pairs state

allocated_pair_addrs = set()
free_pair_addrs = set()

# block_mgr state

blocksets = (
    bytevectors_blockset.value,
    numbers_blockset.value,
    strings_blockset.value,
    vectors_blockset.value,
)

block_mgr_refs_base = block_mgr.calc_initial_refs_top()

block_lists = {}
blocks = {}
allocated_blocks = {}
free_blocks = {}
unused_blocks = {}

# numbers state

x64_blocks = set()
x64s = set()
allocated_x64s = set()
free_x64s = set()

def validate():
    prepare_validation()

    validate_pairs()
    validate_block_mgr()

    validate_bytevectors()
    validate_numbers()
    validate_strings()
    validate_vectors()

    validate_symbols()

    validate_parser()

def prepare_validation():

    initialize_global_state()

    collect_pair_addrs()
    collect_blocks()
    collect_x64_blocks()
    collect_x64s()

def validate_bytevectors():
    ...

def validate_strings():
    ...

def validate_vectors():
    ...

def validate_symbols():
    ...

def validate_parser():
    ...

#-------------------------------------------------------------------------------
#
# Preparation
#

def initialize_global_state():
    allocated_pair_addrs.clear()
    free_pair_addrs.clear()

    block_lists.clear()
    blocks.clear()
    allocated_blocks.clear()
    free_blocks.clear()
    unused_blocks.clear()

    x64_blocks.clear()
    x64s.clear()
    allocated_x64s.clear()
    free_x64s.clear()

# Pairs

def collect_pair_addrs():

    free_pair = pair_free_list.value

    while free_pair != NULL:
        free_pair_addrs.add(free_pair)
        free_pair = get_pair_car(free_pair)

    for addr in range(0, pairs_top.value, pair_size.value):
        if addr not in free_pair_addrs:
            allocated_pair_addrs.add(addr)

# Blocks

def collect_blocks():

    for b in blocksets:
        head = block_lists[b] = block_mgr.get_blockset_block_list(b)
        blks = blocks[b] = set()

        while head != NULL:
            blks.add(head)
            head = block_mgr.get_next_block(head)

        free_blks = free_blocks[b] = set()
        unused_blks = unused_blocks[b] = set()

        for idx, free_list in enumerate(free_lists(b)):
            if free_list is not NULL:
                for block in free_list_blocks(free_list):
                    if block_mgr.is_unused_block(block):
                        unused_blks.add(block)
                    else:
                        free_blks.add(block)

        allocated_blocks[b] = blks - free_blks - unused_blks

def free_lists(blockset):

    free_list = block_mgr.get_blockset_free_lists_base(blockset)
    free_list_top = block_mgr.get_blockset_free_lists_top(blockset)
    while free_list < free_list_top:
        yield block_mgr.get_free_list_head(free_list)
        free_list += 4

def free_list_blocks(free_list):

    while free_list != NULL:
        assert free_list in allocated_pair_addrs
        block = get_pair_car(free_list)
        yield block
        free_list = get_pair_cdr(free_list)

# Bytevectors

# Numbers

def collect_x64_blocks():

    x64_blocks.clear()

    head = numbers.x64_block_list.value

    while head != NULL:
        assert head in allocated_pair_addrs
        block = get_pair_car(head)

        assert block in allocated_blocks[numbers_blockset.value]
        x64_blocks.add(block)

        head = get_pair_cdr(head)

def collect_x64s():

    x64s.clear()
    allocated_x64s.clear()
    free_x64s.clear()

    for b in x64_blocks:
        base_addr = block_mgr.get_block_addr(b)
        for addr in range(base_addr, base_addr + numbers.number_block_size.value, 8):
            x64s.add(addr)

    head = numbers.x64_free_list.value
    while head != NULL:
        free_x64s.add(head)
        head = numbers.get_next_free_x64(head)

    allocated_x64s.update(x64s - free_x64s)

# Strings
# Vectors
# Symbols
# Parse

#-------------------------------------------------------------------------------
#
# Validation
#

# Pairs

def validate_pairs():
    # todo: allocated pair accounting
    # free_count = block_mgr.get_blockset_free_count(blockset)
    # unused_count = block_mgr.get_blockset_unused_count(blockset)

    # assert free_count + unused_count == pair_count.value
    ...

# Blocks

def validate_block_mgr():

    validate_block_refs()

    for b in blocksets:
        assert len(free_blocks[b] - blocks[b]) == 0
        validate_block_list(b)
        validate_free_lists(b)

def validate_block_refs():
    provisioned_refs = (block_mgr.refs_top.value - block_mgr_refs_base)/16

    assert provisioned_refs == block_mgr.ref_count.value + count_free_refs()

    block_count = 0
    unused_count = 0

    for b in blocksets:
        block_count += block_mgr.get_blockset_block_count(b)
        unused_count += block_mgr.get_blockset_unused_count(b)

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

    assert len(free_blocks[blockset]) == free_count
    assert count_fragments(blockset) == block_mgr.get_blockset_fragment_count(blockset)

    for idx, free_list in enumerate(free_lists(blockset)):
        if free_list is not NULL:
            min_size = free_list_idx_to_size(idx)
            for block in free_list_blocks(free_list):
                size = block_mgr.get_block_size(block)
                assert size >= min_size

def count_free_refs():

    count = 0
    head = block_mgr.ref_free_list.value

    while head != NULL:
        head = block_mgr.get_block_addr(head)
        count += 1

    return count

def count_fragments(blockset):

    return sum(len(list(fragments(free_list)))
               for free_list in fragment_lists(blockset))

def fragment_lists(blockset):

    free_list = block_mgr.get_blockset_free_lists_base(blockset)
    free_list_top = block_mgr.get_blockset_free_lists_top(blockset)
    count = 0
    while free_list < free_list_top and count < block_mgr.fragment_size.value:
        yield block_mgr.get_free_list_head(free_list)
        free_list += 4
        count += 1

def fragments(free_list):

    for block in free_list_blocks(free_list):
        if not block_mgr.is_unused_block(block):
            if block_mgr.get_block_size(block) < block_mgr.fragment_size.value:
                yield block

def free_list_idx_to_size(idx):
    shift = block_mgr.alloc_precision_bits.value - 1
    mask = (1 << shift) - 1
    rank = (idx >> shift) - 1
    return ((0 if rank < 0 else 1) << (rank + shift)) + ((idx & mask) << max(0, rank))

# Bytevectors

# Numbers

def validate_numbers():
    validate_x64s()

    assert to_int(numbers.integer_1e16.value)  == 10000000000000000
    assert to_int(numbers.integer_1e32.value)  == 100000000000000000000000000000000
    assert to_int(numbers.integer_1e64.value)  == 10000000000000000000000000000000000000000000000000000000000000000
    assert to_int(numbers.integer_1e128.value) == 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    assert to_int(numbers.integer_1e256.value) == 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

    assert get_value_data(numbers.integer_1e16.value) in allocated_pair_addrs
    assert get_pair_cdr(get_value_data(numbers.integer_1e16.value)) in allocated_blocks[numbers_blockset.value]

def validate_x64s():
    assert len(allocated_x64s - x64s) == 0
    assert len(free_x64s - x64s) == 0
    assert len(free_x64s) + len(allocated_x64s) == len(x64s)
    assert numbers.x64_count.value == len(allocated_x64s)


# Strings

# Symbols

#-------------------------------------------------------------------------------
#
# Utilities
#

def get_value_data(x):
    return x & ~7
