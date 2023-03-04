import random
import sys
import time

from block_mgr_util import (blockset_id, validate_blockset, print_blockset, print_heap,
                            print_block_mgr_state, format_addr)

from modules.debug import block_mgr, block_mgr_test_client, lists, pairs
import util

mgr_blockset_id = block_mgr.block_mgr_blockset_id.value

NULL = block_mgr.NULL.value

def stochastic_perf_test(
        M=1_000_000, # memory target (in bytes)
        seed=0,      # value given to random.seed()
        N=10_000_000 # number of steps
):
    print()

    block_mgr_test_client.init(blockset_id)
    blockset = block_mgr.get_blockset(blockset_id)

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

    problem_step = 4453_0000000
    log_action_min = problem_step-5

    elapsed_ns = 0
    allocs = 0
    deallocs = 0

    alloc_overhead_ns = 0
    for i in range(101000):
        tic = time.perf_counter_ns()
        block_mgr.stub_alloc_block(blockset_id, 1)
        toc = time.perf_counter_ns()
        if i > 1000:
            alloc_overhead_ns += toc - tic

    alloc_overhead_ns /= 100000

    dealloc_overhead_ns = 0
    for i in range(101000):
        tic = time.perf_counter_ns()
        block_mgr.stub_dealloc_block(blockset_id, 1)
        toc = time.perf_counter_ns()
        if i > 1000:
            dealloc_overhead_ns += toc - tic

    dealloc_overhead_ns /= 100000

    def step_action_linear(i):
        r = total_allocated / M

        if r <= 1:
            p = 0.95 * (1 - r) + 0.5 * r
        else:
            p = max(0.5 * (1 - 4*(r - 1)), 0)

        c = random.random() < p

        if i == problem_step or i > log_action_min:
            print('alloc' if c else 'dealloc')

        alloc_block(i) if c or len(blocks) == 0 else dealloc_block(i)

    # Ensure that this is repeatable
    random.seed(seed)
    # random.seed(time.time_ns())

    # Word size
    w = 4

    # average number of w-byte words in each alloc_block request
    L = 5

    # distribution of alloc_block request sizes (in units of w, with exp length L)
    distribution = util.sample_poisson

    def alloc_block(i):
        if i == problem_step:
            block_mgr.DEBUG.value = 1
        nonlocal total_allocated
        nonlocal allocs
        allocs += 1
        size = w * max(1, distribution(L))
        assert size > 0
        if i == problem_step:
            print_blockset(blockset, depth=2)
            block_mgr.DEBUG.value = 1
            print('size:', size)
            block_mgr.provision_blockset_heap(blockset, size)
            print_blockset(blockset, depth=2)
        try:
            tic = time.perf_counter_ns()
            b = block_mgr.alloc_block(blockset_id, size)
            toc = time.perf_counter_ns()
        except:
            # print(format_addr(block_mgr.p1.value))
            # print(format_addr(block_mgr.p2.value))
            # print(format_addr(block_mgr.p3.value))
            raise
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
        if i == problem_step:
            print(format_addr(b))
        #blocks = blocks[:b_i] + blocks[b_i+1:]
        total_allocated -= block_mgr.get_block_size(b)
        if i == problem_step:
            block_mgr.DEBUG.value = 1
            print('pre free')
            stdout = sys.stdout
            sys.stdout = open('out1b.log', 'w')
            print_blockset(blockset)
            sys.stdout = stdout
            print_blockset(blockset, depth=2)
            print_heap(blockset, 2)
            validate_blockset(blockset)
            block_mgr.add_free_block(blockset, b)
            print()
            print('pre clean')
            stdout = sys.stdout
            sys.stdout = open('out2b.log', 'w')
            print_blockset(blockset)
            sys.stdout = stdout
            print_blockset(blockset, depth=2)
            validate_blockset(blockset)
            block_mgr.step_clean_heap(blockset)
            print()
            print('post clean')
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
            #print_blockset(blockset, default_depth)
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

if __name__ == '__main__':
    stochastic_perf_test(M=10_000_000, N=50_000_000)
