SRC_FILES = $(shell find src -name "*.nim")

compile:
	nimble c --outdir:bin src/tetris.nim

format:
	nimpretty $(SRC_FILES)


clean:
	rm bin/*

