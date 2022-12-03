const fs = require("fs");

const wasmModule = new WebAssembly.Module(fs.readFileSync("runtime.wasm"));
const wasmInstance = new WebAssembly.Instance(wasmModule, {});
const { init, cons, car, cdr, mem, error_code, vector_ref, vector_set, make_vector,
        FALSE, TRUE, NULL, is_pair } = wasmInstance.exports;

try {
    const pair = cons(TRUE, FALSE);
    console.log(car(pair) == TRUE, cdr(pair) == FALSE);
} catch (e) {
    console.log(e);
    console.log("error:", error_code.value);
}

try {
    const vector = make_vector(5, TRUE);
    console.log(vector)

} catch (e) {
    console.log(e);
    console.log("vector error:", error_code.value);
}

console.log(new Uint8Array(mem.buffer, 0, 16));
console.log(new Uint8Array(mem.buffer, 65536, 16));
console.log(new Uint8Array(mem.buffer, 65536+4096, 24));
