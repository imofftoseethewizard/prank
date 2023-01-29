%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@

%.wat: %.wam
	${WAM} $*.wam >$@

SOURCES = \
	algorithms.wam \
	block-mgr.wam \
	boxes.wam \
	globals.wam \
	kernel.wam \
	lex.wam \
	memory.wam \
	pairs.wam \
	values.wam \
	vectors.wam

OBJECTS = \
	algorithms.wasm \
	block-mgr.wasm \
	boxes.wasm \
	kernel.wasm \
	lex.wasm \
	memory.wasm \
	pairs.wasm \
	values.wasm \
	vectors.wasm

all: test

objects: ${OBJECTS}

test: ${SOURCES}
	WAM_DEBUG=1 make objects
	${NODE} test.js

.PHONY: all objects test
