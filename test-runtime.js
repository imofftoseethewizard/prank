const fs = require("fs");

const wasmModule = new WebAssembly.Module(fs.readFileSync("runtime.wasm"));
const wasmInstance = new WebAssembly.Instance(wasmModule, {});
const { init, cons, car, cdr, mem, error_code, vector_ref, vector_set, make_vector,
        FALSE, TRUE, NULL, is_pair, next_token, input_buffer, input_buffer_size,
      input_length } = wasmInstance.exports;

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

let utf8Encode = new TextEncoder();

const text = '"1"; foo \n(1) "hello" a';

let inputBuffer = new Uint8Array(mem.buffer, input_buffer.value, input_buffer_size.value);
const bytes = utf8Encode.encode(text);
for (i in bytes) {
    inputBuffer[i] = bytes[i];
}
input_length.value = text.length;

while (true) {
    let [ start, end, token_type ] = next_token();

    console.log(start, end, token_type);
    if (token_type == 3) break;
}
