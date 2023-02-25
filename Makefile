%.d.wasm: %.d.wat
	${WAT2WASM} $*.d.wat -o $@ --debug-names

%.d.wat: %.wam
	${WAM} --debug $*.wam >$@

%.wasm: %.wat
	${WAT2WASM} $*.wat -o $@

%.wat: %.wam
	${WAM} $*.wam >$@

TOOLS = \
	Makefile \
	wam.py \
	test/test_*.py

OBJECTS = \
	block-mgr.wasm \
	block-mgr.d.wasm \
	block-mgr-test-client.wasm \
	block-mgr-test-client.d.wasm \
	bytevectors.wasm \
	bytevectors.d.wasm \
	chars.wasm \
	chars.d.wasm \
	lists.wasm \
	lists.d.wasm \
	pairs.wasm \
	pairs.d.wasm \
	strings.wasm \
	strings.d.wasm \
	vectors.wasm \
	vectors.d.wasm

block-mgr.wat block-mgr.d.wat: globals.wam

block-mgr-test-client.wat block-mgr-test-client.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

boxes.wat boxes.d.wat: globals.wam

bytevectors.wat bytevectors.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	boxes.wam \
	globals.wam \
	values.wam

chars.wat chars.d.wat: globals.wam

lists.wat lists.d.wat: globals.wam

pairs.wat pairs.d.wat: globals.wam gc-client.wam

strings.wat strings.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

vectors.wat vectors.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	block-mgr-test-client.wam \
	globals.wam

all: test

clean:
	rm -f *.wat *.wasm

wasm: ${OBJECTS}

test: wasm ${TOOLS}
	scripts/test-runner.sh

.PHONY: all objects test clean
