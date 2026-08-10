##? zephyr - A Zsh framework as nice as a cool summer breeze
##?
##?	Usage: make <command>
##?
##?	Commands:

.DEFAULT_GOAL := help
all : build help test submodules
.PHONY : all build test testfile submodules help

# Concurrent bats jobs, and the per-test timeout in seconds.
# Override like: make BATS_JOBS=1 test
BATS_JOBS ?= 4
BATS_TEST_TIMEOUT ?= 30
export BATS_JOBS
export BATS_TEST_TIMEOUT

##?   build       run build tasks
build:
	./bin/build_external

##?   test        run the bats test suite
test:
	./tests/run

##?   testfile    run one test file: make testfile FILE=tests/bats/color.bats
testfile:
	@test -n "$(FILE)" || { echo "usage: make testfile FILE=tests/bats/<name>.bats" >&2; exit 2; }
	./tests/run $(FILE)

##?   submodules  update all submodules
submodules:
	git submodule update --recursive --remote

##?   help        show this message
help:
	@grep "^##?" makefile | cut -c 5-
