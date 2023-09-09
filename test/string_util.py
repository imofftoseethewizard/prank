from modules.debug.strings import *
from modules.debug import block_mgr

from util import to_str

NULL = NULL.value

def dump_strings():

    block_list = block_mgr.get_blockset_block_list(strings_blockset.value)

    block = block_list
    while block != NULL:
        block_addr = block_mgr.get_block_addr(block) & 0xffffffff
        size = block_mgr.get_block_size(block)
        print(f'{block} {block_addr:x}: {size}')
        while True:
            try:
                print(to_str(block_addr, block_addr+size))
                break
            except:
                if size == 0:
                    break
                block_addr += 1
                size -= 1

        block = block_mgr.get_next_block(block)
