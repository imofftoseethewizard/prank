.DEFAULT_GOAL := all

obj/debug/%.wasm: obj/debug/src/%.wat
	${WAT2WASM} obj/debug/src/$*.wat -o $@ --debug-names

obj/debug/src/%.wat: src/%.wam
	${WAM} --debug src/$*.wam >$@

obj/%.wasm: obj/src/%.wat
	${WAT2WASM} obj/src/$*.wat -o $@

obj/src/%.wat: src/%.wam
	${WAM} src/$*.wam >$@

TOOLS = \
	Makefile \
	bin/wam.py \
	test/test_*.py

OBJECTS = \
	obj/debug/block-mgr-test-client.wasm \
	obj/debug/block-mgr.wasm \
	obj/debug/bytevectors.wasm \
	obj/debug/chars.wasm \
	obj/debug/lex.wasm \
	obj/debug/lex-r7rs.wasm \
	obj/debug/lists.wasm \
	obj/debug/math.wasm \
	obj/debug/numbers.wasm \
	obj/debug/pairs.wasm \
	obj/debug/parse.wasm \
	obj/debug/strings.wasm \
	obj/debug/symbols.wasm \
	obj/debug/vectors.wasm \
	obj/block-mgr-perf-test.wasm \
	obj/block-mgr-test-client.wasm \
	obj/block-mgr.wasm \
	obj/bytevectors.wasm \
	obj/chars.wasm \
	obj/lex.wasm \
	obj/lex-r7rs.wasm \
	obj/lists.wasm \
	obj/math.wasm \
	obj/numbers.wasm \
	obj/pairs.wasm \
	obj/parse.wasm \
	obj/strings.wasm \
	obj/symbols.wasm \
	obj/vectors.wasm

obj/src/block-mgr.wat obj/debug/src/block-mgr.wat: src/globals.wam

obj/src/block-mgr-perf-test.wat: \
	src/globals.wam

obj/src/block-mgr-test-client.wat obj/debug/src/block-mgr-test-client.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/globals.wam

obj/src/boxes.wat obj/debug/src/boxes.wat: globals.wam

obj/src/bytevectors.wat obj/debug/src/bytevectors.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/src/chars.wat obj/debug/src/chars.wat: \
	src/ascii.wam \
	src/globals.wam \
	src/values.wam

obj/src/lex.wat obj/debug/src/lex.wat: src/globals.wam

obj/src/lex-r7rs.wat obj/debug/src/lex-r7rs.wat: \
	src/ascii.wam \
	src/globals.wam \
	src/lex-r7rs-rule-ids.wam

obj/src/lists.wat obj/debug/src/lists.wat: src/globals.wam

obj/src/numbers.wat obj/debug/src/numbers.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/src/pairs.wat obj/debug/src/pairs.wat: src/globals.wam src/gc-client.wam

obj/src/parse.wat obj/debug/src/parse.wat: \
	src/ascii.wam \
	src/globals.wam \
	src/lex-r7rs-rule-ids.wam \
	src/values.wam

obj/src/strings.wat obj/debug/src/strings.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/src/symbols.wat obj/debug/src/symbols.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/boxes.wam \
	src/globals.wam \
	src/values.wam

obj/src/vectors.wat obj/debug/src/vectors.wat: \
	src/block-mgr-memory-proxies.wam \
	src/block-mgr-memory-proxy-imports.wam \
	src/globals.wam

dirs:
	mkdir -p obj/debug/src
	mkdir -p obj/src
	mkdir -p log

all: test

clean:
	rm -rf obj/*

wasm: ${OBJECTS}

test: dirs wasm ${TOOLS}
	scripts/test-runner.sh

.PHONY: all objects test clean
