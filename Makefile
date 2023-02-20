%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@ --debug-names

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

# OBJECTS = \
# 	algorithms.wasm \
# 	block-mgr.wasm \
# 	boxes.wasm \
# 	kernel.wasm \
# 	lex.wasm \
# 	memory.wasm \
# 	pairs.wasm \
# 	values.wasm \
# 	vectors.wasm

OBJECTS = \
	block-mgr.wasm \
	block-mgr-test-client.wasm \
	boxes.wasm \
	bytevectors.wasm \
	lists.wasm \
	pairs.wasm \
	values.wasm

block-mgr.wat: globals.wam

block-mgr-test-client.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

pairs.wat: pairs.wam globals.wam gc-client.wam

values.wat: values.wam globals.wam

all: test

wasm: ${OBJECTS}

test: ${SOURCES}
	WAM_DEBUG=1 make objects
	${NODE} test.js

.PHONY: all objects test
