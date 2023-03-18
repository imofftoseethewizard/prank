import argparse
import sys
import time

from pathlib import Path

from pprint import *

from wasmer import Module, Instance

from modules import block_mgr, block_mgr_test_client, pairs
from modules._loader import read_wasm_module, store, exports_dict
from util import format_addr

parser = argparse.ArgumentParser(
    prog='block_mgr_perf_runner',
    description='Runs stochastic test suites.')

parser.add_argument('-f', '--fragment-size-bits', default=4, type=int)
parser.add_argument('-p', '--precision-bits', default=4, type=int)
parser.add_argument('-r', '--max-relocation-size', default=0x400, type=int)
parser.add_argument('-M', '--pre-alloc-memory', action='store_true')
parser.add_argument('-n', '--step-count', type=int)
parser.add_argument('filename')

def run_perf(filename, fragment_size_bits, precision_bits, max_relocation_size,
             pre_alloc_memory, step_count):

    data_module = Module(store, Path(filename).read_bytes())
    data_inst = Instance(data_module)
    data_exports = exports_dict(data_inst)

    test_module = read_wasm_module('block-mgr-perf-test')
    imports = {
        'block-mgr': block_mgr.__exports__,
        'data': data_exports,
    }

    test_inst = Instance(test_module, imports)
    test_exports = exports_dict(test_inst)

    init = test_exports['init']
    test = test_exports['test']
    stub_test = test_exports['stub-test']

    block_mgr.alloc_precision_bits.value = precision_bits
    block_mgr.fragment_size.value = 1<<fragment_size_bits
    block_mgr.fragment_size_bits.value = fragment_size_bits

    blockset = 0

    block_mgr.init_blockset(blockset, max_relocation_size)
    block_mgr_test_client.init(blockset)
    init(blockset)

    if step_count is None:
        step_count = (read_i32(bytearray(data_exports['memory'].buffer), 0) >> 2) - 2

    stub_elapsed_ns = 0

    for i in range(10):
        init(blockset)
        tic = time.perf_counter_ns()
        stub_test(step_count)
        toc = time.perf_counter_ns()
        stub_elapsed_ns += toc - tic

    stub_elapsed_ns /= 10

    elapsed_ns = 0

    for i in range(10):
        pairs.init_pairs()
        block_mgr.init_blockset(blockset, 0x1000)
        init(blockset)
        tic = time.perf_counter_ns()
        test(step_count)
        toc = time.perf_counter_ns()
        elapsed_ns += toc - tic

    elapsed_ns /= 10

    alloc_dealloc_pair_count = step_count / 2
    print((elapsed_ns - stub_elapsed_ns)/alloc_dealloc_pair_count)

def read_i32(data, idx):
    result = data[idx]
    result |= data[idx+1]<<8
    result |= data[idx+2]<<16
    result |= data[idx+3]<<24
    return result

if __name__ == '__main__':
    args = parser.parse_args()

    run_perf(
        args.filename,
        fragment_size_bits=args.fragment_size_bits,
        precision_bits=args.precision_bits,
        max_relocation_size=args.max_relocation_size,
        pre_alloc_memory=args.pre_alloc_memory,
        step_count=args.step_count)
