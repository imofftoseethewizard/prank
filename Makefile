%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@ --debug-names

%.wat: %.wam
	${WAM} $*.wam >$@

SOURCES = \
	algorithms.wam \
	block-mgr.wam \
	boxes.wam \
	bytevectors.wam \
	globals.wam \
	kernel.wam \
	lex.wam \
	memory.wam \
	pairs.wam \
	values.wam \
	vectors.wam

# OBJECTS = \
# 	algorithms.wasm \
# 	kernel.wasm \
# 	lex.wasm \
# 	vectors.wasm

OBJECTS = \
	block-mgr.wasm \
	block-mgr-test-client.wasm \
	boxes.wasm \
	bytevectors.wasm \
	chars.wasm \
	lists.wasm \
	pairs.wasm \
#	strings.wasm \
	values.wasm \
	vectors.wasm

block-mgr.wat: globals.wam

block-mgr-test-client.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

boxes.wat: globals.wam

bytevectors.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

chars.wam: globals.wam

lists.wam: globals.wam

pairs.wat: globals.wam gc-client.wam

strings.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

values.wat: globals.wam

vectors.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

all: test

wasm: ${OBJECTS}

test: ${SOURCES}
	WAM_DEBUG=1 make objects
	${NODE} test.js

.PHONY: all objects test
