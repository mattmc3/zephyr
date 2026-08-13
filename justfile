# zephyr - A Zsh framework as nice as a cool summer breeze

# Concurrent bats jobs, and the per-test timeout in seconds.
# Override like: just BATS_JOBS=1 test
export BATS_JOBS := env("BATS_JOBS", "4")
export BATS_TEST_TIMEOUT := env("BATS_TEST_TIMEOUT", "30")

# show this message
help:
  @just --list --unsorted

# run build, test, and submodule tasks
all: build test submodules

# run build tasks
build:
  ./bin/build_external

# run the bats test suite
test:
  ./tests/run

# run one test file: just testfile tests/bats/color.bats
testfile FILE:
  ./tests/run {{ FILE }}

# run prettier over the markdown files
format:
  @command -v npx >/dev/null || { echo "just format: npx not found" >&2; exit 127; }
  npx --yes prettier --write --print-width 88 --prose-wrap always $(git ls-files '*.md')

# update all submodules
submodules:
  git submodule update --recursive --remote
