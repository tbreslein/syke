SYKE_BIN := zig-out/bin/syke

.PHONY: all build run test clean

all: ${SYKE_BIN}

${SYKE_BIN}: build

build:
	zig build

run:
	zig build run

test:
	zig build test

clean:
	rm -fr ./.zig-cache/ ./zig-out/
