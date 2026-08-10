#!/usr/bin/env bats
# Cross-platform command fill-ins and clipboard helpers.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the utility functions are defined" {
  zephyr_plugin utility <<'EOS'
for f in sedi copyfile copypath; do
  (( $+functions[$f] )) || print "missing: $f"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

@test "a dumb terminal turns the plugin off" {
  zephyr_zsh <<'EOS'
export TERM=dumb
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/utility/utility.plugin.zsh
print "exit: $?"
EOS
  assert_success
  assert_line "exit: 1"
}

@test "help is aliased to run-help" {
  zephyr_plugin utility 'print "help: $aliases[help]"'
  assert_success
  assert_line "help: run-help"
}

@test "ls gets a human readable size flag" {
  zephyr_plugin utility 'print "ls: $aliases[ls]"'
  assert_success
  assert_output_contains "ls: ls"
  assert_output_contains "-h"
}

@test "the ls alias composes onto an existing one" {
  zephyr_zsh <<'EOS'
alias ls='eza --color=auto'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/utility/utility.plugin.zsh
print "ls: $aliases[ls]"
EOS
  assert_success
  assert_output_contains "eza --color=auto"
  assert_output_contains "-h"
}

# $path is narrowed to the stub dir alone, so `python` and `pip` are genuinely
# absent. The GitHub Linux runners ship both, which would otherwise suppress the
# aliases. Nothing past this point runs an external command.
@test "python and pip fall back to their 3 spellings" {
  stub_command python3 'print py3'
  stub_command pip3 'print pip3'
  zephyr_zsh <<'EOS'
path=($HOME/bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/utility/utility.plugin.zsh
print "python: ${aliases[python]:-unset}"
print "pip: ${aliases[pip]:-unset}"
EOS
  assert_success
  assert_line "python: python3"
  assert_line "pip: pip3"
}

@test "a real python is left alone" {
  stub_command python3 'print py3'
  stub_command python 'print py'
  zephyr_plugin utility 'print "python: ${aliases[python]:-unset}"'
  assert_success
  assert_line "python: unset"
}

# Debian ships an `hd` of its own, so the stub dir has to be the whole of $path.
@test "hd falls back to hexdump" {
  stub_command hexdump 'print hd'
  zephyr_zsh <<'EOS'
path=($HOME/bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/utility/utility.plugin.zsh
print "hd: ${aliases[hd]:-unset}"
EOS
  assert_success
  assert_line "hd: hexdump -C"
}

#
# Clipboard helpers, driven against a fake pbcopy so nothing touches the real
# clipboard.
#

@test "copyfile sends a file's contents to the clipboard" {
  zephyr_plugin utility <<'EOS'
function pbcopy { cat >$HOME/clip }
print "file contents here" >$HOME/src.txt
copyfile $HOME/src.txt
print "clip: $(<$HOME/clip)"
EOS
  assert_success
  assert_line "clip: file contents here"
}

@test "copyfile rejects a missing file" {
  zephyr_plugin utility <<'EOS'
function pbcopy { cat >$HOME/clip }
copyfile $HOME/nope
print "exit: $?"
EOS
  assert_success
  assert_output_contains "copyfile: not a file:"
  assert_line "exit: 1"
}

@test "copyfile rejects a directory" {
  zephyr_plugin utility <<'EOS'
function pbcopy { cat >$HOME/clip }
copyfile $HOME
print "exit: $?"
EOS
  assert_success
  assert_output_contains "copyfile: not a file:"
  assert_line "exit: 1"
}

@test "copypath copies an absolute path" {
  zephyr_plugin utility <<'EOS'
function pbcopy { cat >$HOME/clip }
mkdir -p $HOME/one/two
copypath $HOME/one/../one/two
print "clip: ${$(<$HOME/clip)#$HOME/}"
EOS
  assert_success
  assert_line "clip: one/two"
}

@test "copypath defaults to the current directory" {
  zephyr_plugin utility <<'EOS'
function pbcopy { cat >$HOME/clip }
mkdir -p $HOME/somewhere
cd $HOME/somewhere
copypath
print "clip: ${$(<$HOME/clip)#$HOME/}"
EOS
  assert_success
  assert_line "clip: somewhere"
}

@test "copypath writes no trailing newline" {
  zephyr_plugin utility <<'EOS'
function pbcopy { cat >$HOME/clip }
copypath $HOME
print "bytes: $(wc -c <$HOME/clip | tr -d ' ')"
print "want: $#HOME"
EOS
  assert_success
  local want
  want="$(grep '^want: ' <<<"$output" | cut -d' ' -f2)"
  assert_line "bytes: $want"
}

@test "sedi edits a file in place" {
  zephyr_plugin utility <<'EOS'
print "hello world" >$HOME/f.txt
sedi 's/world/zsh/' $HOME/f.txt
print "content: $(<$HOME/f.txt)"
EOS
  assert_success
  assert_line "content: hello zsh"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:utility' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/utility/utility.plugin.zsh
print "sedi: $+functions[sedi]"
print "copyfile: $+functions[copyfile]"
EOS
  assert_success
  assert_line "sedi: 0"
  assert_line "copyfile: 0"
}
