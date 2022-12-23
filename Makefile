%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@

SOURCES = algorithms.wat kernel.wat lex.wat memory.wat

all: test

test: algorithms.wat
	${NODE} test.js

.PHONY: all test
