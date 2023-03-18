obj/%.d.wasm: obj/%.d.wat
	${WAT2WASM} obj/$*.d.wat -o $@ --debug-names

obj/%.d.wat: src/%.wam
	${WAM} --debug src/$*.wam >$@

obj/%.wasm: obj/%.wat
	${WAT2WASM} obj/$*.wat -o $@

obj/%.wat: src/%.wam
	${WAM} src/$*.wam >$@

TOOLS = \
	Makefile \
	wam.py \
	test/test_*.py

OBJECTS = \
	obj/block-mgr.wasm \
	obj/block-mgr.d.wasm \
	obj/block-mgr-perf-test.wasm \
	obj/block-mgr-test-client.wasm \
	obj/block-mgr-test-client.d.wasm \
	obj/bytevectors.wasm \
	obj/bytevectors.d.wasm \
	obj/chars.wasm \
	obj/chars.d.wasm \
	obj/lists.wasm \
	obj/lists.d.wasm \
	obj/numbers.wasm \
	obj/numbers.d.wasm \
	obj/pairs.wasm \
	obj/pairs.d.wasm \
	obj/strings.wasm \
	obj/strings.d.wasm \
	obj/symbols.wasm \
	obj/symbols.d.wasm \
	obj/vectors.wasm \
	obj/vectors.d.wasm

obj/block-mgr.wat obj/block-mgr.d.wat: src/globals.wam

obj/block-mgr-perf-test.wat: \
	src/globals.wam

obj/block-mgr-test-client.wat obj/block-mgr-test-client.d.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/globals.wam

obj/boxes.wat obj/boxes.d.wat: globals.wam

obj/bytevectors.wat obj/bytevectors.d.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/chars.wat obj/chars.d.wat: src/globals.wam src/values.wam

obj/lists.wat obj/lists.d.wat: src/globals.wam

obj/numbers.wat obj/numbers.d.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/pairs.wat obj/pairs.d.wat: src/globals.wam src/gc-client.wam

obj/strings.wat obj/strings.d.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/symbols.wat obj/symbols.d.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/vectors.wat obj/vectors.d.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/globals.wam

all: test

clean:
	rm -f obj/*

wasm: ${OBJECTS}

test: wasm ${TOOLS}
	scripts/test-runner.sh

.PHONY: all objects test clean
