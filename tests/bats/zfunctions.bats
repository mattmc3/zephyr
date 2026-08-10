#!/usr/bin/env bats
# Autoloading a functions directory, and the func* helpers.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the zfunctions helpers are defined" {
  zephyr_plugin zfunctions <<'EOS'
for f in autoload-dir funcsave funced funcfresh; do
  (( $+functions[$f] )) || print "missing: $f"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

@test "ZFUNCDIR defaults into the zsh config dir" {
  zephyr_plugin zfunctions 'print "zfuncdir: ${ZFUNCDIR#$HOME/}"'
  assert_success
  assert_line "zfuncdir: .config/zsh/functions"
}

@test "the directory zstyle moves it, and expands a leading tilde" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:zfunctions' directory '~/myfuncs'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/zfunctions/zfunctions.plugin.zsh
print "zfuncdir: ${ZFUNCDIR#$HOME/}"
EOS
  assert_success
  assert_line "zfuncdir: myfuncs"
}

@test "a preset ZFUNCDIR wins" {
  zephyr_zsh <<'EOS'
ZFUNCDIR=$HOME/preset
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/zfunctions/zfunctions.plugin.zsh
print "zfuncdir: ${ZFUNCDIR#$HOME/}"
EOS
  assert_success
  assert_line "zfuncdir: preset"
}

@test "functions in ZFUNCDIR are autoloadable and run" {
  write_file "$TEST_HOME/.config/zsh/functions/greet" 'print "hello from greet"'
  zephyr_plugin zfunctions <<'EOS'
print "autoloadable: $+functions[greet]"
greet
EOS
  assert_success
  assert_line "autoloadable: 1"
  assert_line "hello from greet"
}

@test "ZFUNCDIR joins fpath" {
  write_file "$TEST_HOME/.config/zsh/functions/greet" 'print hi'
  zephyr_plugin zfunctions <<'EOS'
local -a m=(${(M)fpath:#$ZFUNCDIR})
print "in fpath: $#m"
EOS
  assert_success
  assert_line "in fpath: 1"
}

@test "subdirectories of ZFUNCDIR are autoloaded too" {
  write_file "$TEST_HOME/.config/zsh/functions/nested/deepfn" 'print "from deepfn"'
  zephyr_plugin zfunctions <<'EOS'
print "autoloadable: $+functions[deepfn]"
deepfn
EOS
  assert_success
  assert_line "autoloadable: 1"
  assert_line "from deepfn"
}

# Completion functions belong to compinit, not here.
@test "underscore-prefixed files are not autoloaded" {
  write_file "$TEST_HOME/.config/zsh/functions/_mycomp" 'print nope'
  zephyr_plugin zfunctions 'print "loaded: $+functions[_mycomp]"'
  assert_success
  assert_line "loaded: 0"
}

@test "a missing ZFUNCDIR is not an error" {
  zephyr_zsh <<'EOS'
ZFUNCDIR=$HOME/nothing-here
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/zfunctions/zfunctions.plugin.zsh
print "exit: $?"
EOS
  assert_success
  assert_line "exit: 0"
}

@test "autoload-dir adds a directory and autoloads its files" {
  write_file "$TEST_HOME/extra/extrafn" 'print "from extrafn"'
  zephyr_plugin zfunctions <<'EOS'
autoload-dir $HOME/extra
print "autoloadable: $+functions[extrafn]"
extrafn
EOS
  assert_success
  assert_line "autoloadable: 1"
  assert_line "from extrafn"
}

@test "funcsave writes a function body to ZFUNCDIR" {
  zephyr_plugin zfunctions <<'EOS'
mkdir -p $ZFUNCDIR
function mynewfn {
  print "saved body"
}
funcsave mynewfn
print "file: $([[ -s $ZFUNCDIR/mynewfn ]] && print exists || print missing)"
print "body: $(<$ZFUNCDIR/mynewfn)"
EOS
  assert_success
  assert_line "file: exists"
  assert_line "body: print \"saved body\""
}

@test "funcsave rejects an unknown function" {
  zephyr_plugin zfunctions <<'EOS'
mkdir -p $ZFUNCDIR
funcsave nope-not-a-function
print "exit: $?"
EOS
  assert_success
  assert_output_contains "Unknown function"
  assert_line "exit: 1"
}

@test "funcsave with no arguments fails" {
  zephyr_plugin zfunctions 'funcsave; print "exit: $?"'
  assert_success
  assert_output_contains "Expected at least 1 args"
  assert_line "exit: 1"
}

@test "funcfresh reloads a function from disk" {
  write_file "$TEST_HOME/.config/zsh/functions/changing" 'print "first version"'
  zephyr_plugin zfunctions <<'EOS'
changing
print 'print "second version"' >$ZFUNCDIR/changing
funcfresh changing
changing
EOS
  assert_success
  assert_line "first version"
  assert_line "second version"
}

@test "funcfresh rejects an unknown function" {
  zephyr_plugin zfunctions <<'EOS'
funcfresh nope-not-a-function
print "exit: $?"
EOS
  assert_success
  assert_output_contains "Function not found"
  assert_line "exit: 1"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:zfunctions' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/zfunctions/zfunctions.plugin.zsh
print "funcsave: $+functions[funcsave]"
EOS
  assert_success
  assert_line "funcsave: 0"
}
