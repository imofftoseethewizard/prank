%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@

%.wat: %.wam
	${WAM} $*.wam >$@

SOURCES = algorithms.wat kernel.wat lex.wat memory.wat
OBJECTS = algorithms.wasm kernel.wasm lex.wasm memory.wasm

all: test

test: ${OBJECTS}
	${NODE} test.js

.PHONY: all test
