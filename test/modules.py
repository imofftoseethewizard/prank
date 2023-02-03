from pathlib import Path
from wasmer import engine, Store, Module, Instance
from wasmer_compiler_cranelift import Compiler

engine = engine.Universal(Compiler)
store = Store()

def module_wasm_path(name):
    return Path.home() / 'src' / 'crack' / f'{name}.wasm'

def module_wat_path(name):
    return Path.home() / 'src' / 'crack' / f'{name}.wat'

def read_wasm_module(name):
    return Module(store, module_wasm_path(name).read_bytes())

def read_wat_module(name):
    return Module(store, module_wat_path(name).read_text())

def export_name_to_identifier(export_name):
    if export_name.startswith('#'):
        export_name = export_name[1:].upper()

    return export_name.replace('-', '_')

def exports_dict(instance):
    return dict(iter(instance.exports))

def module_exports_object(name, module, dependencies=[]):

    imports = {
        dep.__name__: dep.__exports__
        for dep in dependencies
    }

    instance = Instance(module, imports)

    exports = exports_dict(instance)

    attrs = {
        export_name_to_identifier(k): v
        for k, v in exports.items()
    }

    return type(name, (), { '__exports__': exports, '__slots__': [], **attrs })

def wasm_exports_object(name, *dependencies):
    return module_exports_object(name, read_wasm_module(name), dependencies)

pairs = wasm_exports_object('pairs')
values = wasm_exports_object('values')

block_mgr = wasm_exports_object('block-mgr', pairs, values)
block_mgr_test_client = wasm_exports_object('block-mgr-test-client', block_mgr)

lists = wasm_exports_object('lists', pairs)
