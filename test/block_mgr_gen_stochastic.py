import argparse
import random
import sys
import time

from block_mgr_util import (blockset, validate_blockset, print_blockset,
                            print_block_mgr_state, format_addr)

from modules import block_mgr, block_mgr_test_client, lists, pairs
import util

parser = argparse.ArgumentParser(
    prog='block_mgr_gen_stochastic',
    description='Generates stochastic test data sets for alloc/dealloc.')

parser.add_argument('-w', '--word-size', default=4, type=int, dest='w')
parser.add_argument('-L', '--average-length', default=5, type=int, dest='L')
parser.add_argument('-M', '--memory-target', default=1_000_000, type=int, dest='M')
parser.add_argument('-S', '--random-seed', default=0, type=int, dest='seed')
parser.add_argument('-N', '--steps', default=100_000, type=int, dest='N')

nNULL = block_mgr.NULL.value

def generate_data(
        w=1,  # word size
        L=3,  # average length of alloc request in words
        M=50_000_000, # memory target (in bytes)
        seed=0,      # value given to random.seed()
        N=10_000_000 # number of steps
):
    # This will hold the blocks that have been allocated
    blocks = []

    # This tracks the total bytes allocated in `blocks`
    total_allocated = 0

    # Target 1 MB of allocations

    # When total_allocated == M, the probability of allocating a block at
    # a step should be 50%. For simplicity, these probabilities will have
    # a linear envelope, starting at 95% at 0 total allocated, dropping
    # to 50% at M, and then falling to 0 by M * 1.25.

    allocs = 0
    deallocs = 0

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

    # distribution of alloc_block request sizes (in units of w, with exp length L)
    distribution = util.sample_poisson

    # one address for the length of the data, another for the number of block
    # addresses that will be required, plus one address per step, each address
    # being 4 bytes long
    B = (N + 2) << 2

    # data is prefixed with its length
    data = [B, 0]

    max_blocks = 0

    alloc_flag = 0x8000_0000

    def alloc_block(i):
        nonlocal max_blocks
        nonlocal total_allocated
        nonlocal allocs
        allocs += 1
        size = w * max(1, distribution(L))
        blocks.append(size)
        max_blocks = max(max_blocks, len(blocks))
        data.append(alloc_flag | size)
        total_allocated += size

    def dealloc_block(i):
        nonlocal total_allocated
        nonlocal deallocs
        deallocs += 1
        b_i = random.randrange(len(blocks))
        data.append(B + (b_i << 2))
        size = blocks[b_i]
        blocks[b_i] = blocks[-1]
        blocks.pop()
        total_allocated -= size

    for i in range(N):
        step_action_linear(i)

    # number of memory pages required to run the test
    page_count = ((B + (max_blocks << 2)) + 0xffff) >> 16
    data[1] = page_count

    data_bytes = bytearray(len(data) << 2)

    for idx, x in enumerate(data):
        i = idx << 2
        data_bytes[i] = x & 0xff
        x >>= 8
        data_bytes[i+1] = x & 0xff
        x >>= 8
        data_bytes[i+2] = x & 0xff
        x >>= 8
        data_bytes[i+3] = x & 0xff
        x >>= 8

    f = open(f'block-mgr-stochastic-L-{L}-w-{w}-M-{M}-N-{N}-seed-{seed}.wat', 'w')
    f.write('(module\n')
    f.write(f'  (memory (export "memory") {page_count})\n')
    f.write(f'  (global (export "L") i32 (i32.const {L}))\n')
    f.write(f'  (global (export "M") i32 (i32.const {M}))\n')
    f.write(f'  (global (export "N") i32 (i32.const {N}))\n')
    f.write(f'  (global (export "seed") i32 (i32.const {seed}))\n')
    f.write(f'  (global (export "w") i32 (i32.const {w}))\n')
    for line_addr in range(0, len(data_bytes), 1024):
        f.write(f'  (data (offset (i32.const {format_addr(line_addr)})) "')
        for addr in range(line_addr, min(line_addr+1024, len(data_bytes))):
            f.write(f'\\{data_bytes[addr]:02x}')
        f.write(f'")\n')
    f.write(')\n')
    f.close()

if __name__ == '__main__':
    generate_data(**vars(parser.parse_args()))
