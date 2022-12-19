%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@

all: test

test: crack.wasm
	${NODE} test.js

.PHONY: all test
