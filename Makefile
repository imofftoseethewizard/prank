obj/%.d.wasm: obj/%.d.wat
	${WAT2WASM} obj/$*.d.wat -o $@ --debug-names

obj/%.d.wat: %.wam
	${WAM} --debug $*.wam >$@

obj/%.wasm: obj/%.wat
	${WAT2WASM} obj/$*.wat -o $@

obj/%.wat: %.wam
	${WAM} $*.wam >$@

TOOLS = \
	Makefile \
	wam.py \
	test/test_*.py

OBJECTS = \
	obj/block-mgr.wasm \
	obj/block-mgr.d.wasm \
	obj/block-mgr-test-client.wasm \
	obj/block-mgr-test-client.d.wasm \
	obj/bytevectors.wasm \
	obj/bytevectors.d.wasm \
	obj/chars.wasm \
	obj/chars.d.wasm \
	obj/lists.wasm \
	obj/lists.d.wasm \
	obj/pairs.wasm \
	obj/pairs.d.wasm \
	obj/strings.wasm \
	obj/strings.d.wasm \
	obj/symbols.wasm \
	obj/symbols.d.wasm \
	obj/vectors.wasm \
	obj/vectors.d.wasm

obj/block-mgr.wat obj/block-mgr.d.wat: globals.wam

obj/block-mgr-test-client.wat obj/block-mgr-test-client.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	globals.wam

obj/boxes.wat obj/boxes.d.wat: globals.wam

obj/bytevectors.wat obj/bytevectors.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	boxes.wam \
	globals.wam \
	values.wam

obj/chars.wat obj/chars.d.wat: globals.wam values.wam

obj/lists.wat obj/lists.d.wat: globals.wam

obj/pairs.wat obj/pairs.d.wat: globals.wam gc-client.wam

obj/strings.wat obj/strings.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	boxes.wam \
	globals.wam \
	values.wam

obj/symbols.wat obj/symbols.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	boxes.wam \
	globals.wam \
	values.wam

obj/vectors.wat obj/vectors.d.wat: \
	block-mgr-memory-proxies.wam \
	block-mgr-memory-proxy-imports.wam \
	globals.wam

all: test

clean:
	rm -f obj/*

wasm: ${OBJECTS}

test: wasm ${TOOLS}
	scripts/test-runner.sh

.PHONY: all objects test clean
