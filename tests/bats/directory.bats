#!/usr/bin/env bats
# Directory options, dirstack aliases, and the up function.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the directory options are set" {
  zephyr_plugin directory <<'EOS'
for opt in auto_pushd pushd_ignore_dups pushd_minus pushd_silent pushd_to_home \
           multios extended_glob glob_dots; do
  [[ -o $opt ]] || print "expected on: $opt"
done
for opt in clobber rm_star_silent; do
  [[ -o $opt ]] && print "expected off: $opt"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "expected on:"
  refute_output_contains "expected off:"
}

@test "the dirstack and backref aliases are set" {
  zephyr_plugin directory <<'EOS'
print "dash: $aliases[-]"
print "dirh: $aliases[dirh]"
print "two: $aliases[2]"
print "nine: $aliases[9]"
print "dotdot2: $galiases[..2]"
print "dotdot3: $galiases[..3]"
EOS
  assert_success
  assert_line "dash: cd -"
  assert_line "dirh: dirs -v"
  assert_line "two: cd -2"
  assert_line "nine: cd -9"
  assert_line "dotdot2: ../.."
  assert_line "dotdot3: ../../.."
}

@test "the alias skip zstyle suppresses them" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:directory:alias' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/directory/directory.plugin.zsh
print "dirh: $+aliases[dirh]"
print "dotdot2: $+galiases[..2]"
print "up: $+functions[up]"
EOS
  assert_success
  assert_line "dirh: 0"
  assert_line "dotdot2: 0"
  assert_line "up: 1"
}

# pushd_ignore_dups keeps the numbered cd aliases pointing at distinct places.
# Contrasted against the option turned off, so the assertion shows the option is
# what makes the difference rather than some other dirstack behavior.
@test "pushd_ignore_dups keeps a repeated directory off the dirstack" {
  zephyr_plugin directory <<'EOS'
mkdir -p $HOME/a $HOME/b
cd $HOME/a; dirstack=()
pushd -q $HOME/b; pushd -q $HOME/b; pushd -q $HOME/b
print "with option: $#dirstack"

unsetopt pushd_ignore_dups
cd $HOME/a; dirstack=()
pushd -q $HOME/b; pushd -q $HOME/b; pushd -q $HOME/b
print "without option: $#dirstack"
EOS
  assert_success
  assert_line "with option: 1"
  assert_line "without option: 3"
}

@test "up walks the given number of parents" {
  zephyr_plugin directory <<'EOS'
mkdir -p $HOME/one/two/three
cd $HOME/one/two/three
up 2
print "pwd: ${PWD#$HOME/}"
EOS
  assert_success
  assert_line "pwd: one"
}

@test "up with no argument goes up one" {
  zephyr_plugin directory <<'EOS'
mkdir -p $HOME/one/two
cd $HOME/one/two
up
print "pwd: ${PWD#$HOME/}"
EOS
  assert_success
  assert_line "pwd: one"
}

@test "up rejects a non-positive count" {
  zephyr_plugin directory <<'EOS'
up 0
print "exit: $?"
up -3
print "exit: $?"
EOS
  assert_success
  assert_output_contains "usage: up [<num>]"
  assert_line "exit: 1"
}
