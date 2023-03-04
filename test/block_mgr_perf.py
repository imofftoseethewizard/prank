import random
import sys
import time

from block_mgr_util import (blockset_id, validate_blockset, print_blockset, print_heap,
                            print_block_mgr_state, format_addr)

from modules import block_mgr, block_mgr_test_client, lists, pairs, values
import util

NULL = block_mgr.NULL.value

def stochastic_perf_test(
        M=1_000_000, # memory target (in bytes)
        seed=0,      # value given to random.seed()
        N=10_000_000 # number of steps
):
    print()

    block_mgr_test_client.init(blockset_id)

    # default 0x1000
    block_mgr.set_blockset_relocation_size_limit(blockset_id, 0x1000)

    # default 0x1000
    block_mgr.set_blockset_immobile_block_size(blockset_id, 0x8000)

    # This will hold the blocks that have been allocated
    blocks = []

    # This tracks the total bytes allocated in `blocks`
    total_allocated = 0

    # Target 1 MB of allocations

    # When total_allocated == M, the probability of allocating a block at
    # a step should be 50%. For simplicity, these probabilities will have
    # a linear envelope, starting at 95% at 0 total allocated, dropping
    # to 50% at M, and then falling to 0 by M * 1.25.

    elapsed_ns = 0
    allocs = 0
    deallocs = 0

    alloc_overhead_ns = 0
    for i in range(10100):
        tic = time.perf_counter_ns()
        block_mgr.stub_alloc_block(blockset_id, 1)
        toc = time.perf_counter_ns()
        if i > 100:
            alloc_overhead_ns += toc - tic

    alloc_overhead_ns /= 10000

    dealloc_overhead_ns = 0
    for i in range(10100):
        tic = time.perf_counter_ns()
        block_mgr.stub_dealloc_block(blockset_id, 1)
        toc = time.perf_counter_ns()
        if i > 100:
            dealloc_overhead_ns += toc - tic

    dealloc_overhead_ns /= 10000

    def step_action_linear(i):
        r = total_allocated / M

        if r <= 1:
            p = 0.95 * (1 - r) + 0.5 * r
        else:
            p = max(0.5 * (1 - 4*(r - 1)), 0)

        c = random.random() < p

        alloc_block(i) if c or len(blocks) == 0 else dealloc_block(i)

    # Ensure that this is repeatable
    random.seed(seed)

    # Word size
    w = 4

    # average number of w-byte words in each alloc_block request
    L = 5

    # distribution of alloc_block request sizes (in units of w, with exp length L)
    distribution = util.sample_poisson

    def alloc_block(i):
        nonlocal total_allocated
        nonlocal allocs
        allocs += 1
        size = w * max(1, distribution(L))
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
        blocks[b_i] = blocks[-1]
        blocks.pop()
        total_allocated -= block_mgr.get_block_size(b)
        tic = time.perf_counter_ns()
        block_mgr.dealloc_block(blockset_id, b)
        toc = time.perf_counter_ns()
        nonlocal elapsed_ns
        elapsed_ns += toc - tic


    for i in range(N):
        step_action_linear(i)

    print(f'raw allocator time: {elapsed_ns/1_000_000_000:0.4f}')
    adjusted_elapsed_ns = elapsed_ns - allocs * alloc_overhead_ns - deallocs * dealloc_overhead_ns
    print(f'adjusted allocator time: {adjusted_elapsed_ns/1_000_000_000:0.4f}')
    print(f'amortized ns per alloc-dealloc pair:', adjusted_elapsed_ns/(N/2))
    print(f'allocator overhead {alloc_overhead_ns} ns, deallocator overhead {dealloc_overhead_ns} ns')
    print(f'allocations: {allocs}, deallocations: {deallocs}')

if __name__ == '__main__':
    stochastic_perf_test()
