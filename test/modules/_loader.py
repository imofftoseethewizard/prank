from pathlib import Path
from wasmer import engine, Store, Module, Instance
from wasmer_compiler_cranelift import Compiler

engine = engine.Universal(Compiler)
store = Store()

def module_wasm_path(name, debug=False):
    if debug:
        name += '.d'
    print(name)
    return Path.home() / 'src' / 'prank' / f'{name}.wasm'

def module_wat_path(name, debug=False):
    if debug:
        name += '.d'
    return Path.home() / 'src' / 'prank' / f'{name}.wat'

def read_wasm_module(name, debug=False):
    return Module(store, module_wasm_path(name, debug=debug).read_bytes())

def read_wat_module(name, debug=False):
    return Module(store, module_wat_path(name, debug=debug).read_text())

def export_name_to_identifier(export_name):
    if export_name.startswith('#'):
        export_name = export_name[1:].upper()

    return export_name.replace('-', '_')

def exports_dict(instance):
    return dict(iter(instance.exports))

def init_module(globals, name, *dependencies, debug=False):

    module = read_wasm_module(name, debug=debug)

    imports = {
        dep.__module_name__: dep.__exports__
        for dep in dependencies
    }

    from pprint import pprint
    pprint(imports)
    instance = Instance(module, imports)

    exports = exports_dict(instance)

    attrs = {
        export_name_to_identifier(k): v
        for k, v in exports.items()
    }

    globals.update({ '__module_name__': name, '__exports__': exports, **attrs })
