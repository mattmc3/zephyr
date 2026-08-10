#!/usr/bin/env bats
# macOS-only functions.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the plugin bows out on a non-macOS system" {
  zephyr_zsh <<'EOS'
OSTYPE=linux-gnu
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/macos/macos.plugin.zsh
print "exit: $?"
print "cdf: $+functions[cdf]"
EOS
  assert_success
  assert_line "exit: 1"
  assert_line "cdf: 0"
}

@test "the functions are autoloadable on macOS" {
  [[ "$OSTYPE" == darwin* ]] || skip "macOS only"
  zephyr_plugin macos <<'EOS'
for f in cdf ofd pfd pfs peek trash manp mand lmk flushdns \
         showfiles hidefiles rmdsstore pushdf; do
  (( $+functions[$f] )) || print "missing: $f"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

@test "the functions directory joins fpath" {
  [[ "$OSTYPE" == darwin* ]] || skip "macOS only"
  zephyr_plugin macos <<'EOS'
local -a m=(${(M)fpath:#$ZEPHYR_HOME/plugins/macos/functions})
print "in fpath: $#m"
EOS
  assert_success
  assert_line "in fpath: 1"
}

@test "the skip zstyle keeps the plugin out entirely" {
  [[ "$OSTYPE" == darwin* ]] || skip "macOS only"
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:macos' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/macos/macos.plugin.zsh
print "cdf: $+functions[cdf]"
EOS
  assert_success
  assert_line "cdf: 0"
}

@test "trash refuses to run with no arguments" {
  [[ "$OSTYPE" == darwin* ]] || skip "macOS only"
  zephyr_plugin macos <<'EOS'
trash
print "exit: $?"
EOS
  assert_success
  refute_line "exit: 0"
}
