%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@

SOURCES = algorithms.wat kernel.wat lex.wat memory.wat
OBJECTS = algorithms.wasm kernel.wasm lex.wasm memory.wasm

all: test

test: ${OBJECTS}
	${NODE} test.js

.PHONY: all test
