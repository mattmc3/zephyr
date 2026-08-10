#!/usr/bin/env bats
# The shared functions: predicates defined in lib/bootstrap.zsh, and the bigger ones
# autoloaded from functions/.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

# Sourcing bootstrap is enough. There is no helper plugin to load.
@test "bootstrap alone provides every shared function" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
for f in cached-eval gen-uuid7 is-autoloadable is-callable is-true is-macos \
         is-linux is-bsd is-cygwin is-termux is-term-family is-tmux; do
  (( $+functions[$f] )) || print "missing: $f"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

# lib/bootstrap.zsh finds ZEPHYR_HOME and nothing else. The work is an autoloaded
# function, so it has its own file and its own history.
@test "bootstrap.zsh is a thin door onto zephyr-bootstrap" {
  zephyr_zsh <<'EOS'
print "before: zephyr-bootstrap defined=$+functions[zephyr-bootstrap] loaded=$(zstyle -t ':zephyr:lib:bootstrap' loaded && print yes || print no)"
source $ZEPHYR_HOME/lib/bootstrap.zsh
print "after: loaded=$(zstyle -t ':zephyr:lib:bootstrap' loaded && print yes || print no)"
EOS
  assert_success
  assert_line "before: zephyr-bootstrap defined=0 loaded=no"
  assert_line "after: loaded=yes"
}

# A caller who set ksh_arrays would collapse $fpath to its first element when
# bootstrap prepends to it, taking Zsh's own function directories with it, so
# add-zsh-hook could not be found and post_zshrc never registered.
@test "bootstrapping survives a caller with hostile options" {
  zephyr_zsh <<'EOS'
before=$#fpath
setopt ksh_arrays sh_word_split
source $ZEPHYR_HOME/lib/bootstrap.zsh
() { emulate -L zsh
  print "fpath grew by one: $(( $#fpath - before ))"
  local -a z=(${(M)fpath:#*share/zsh*})
  print "zsh function dirs kept: $(( $#z > 0 ))"
}
print "precmd registered: $(add-zsh-hook -L precmd 2>/dev/null | grep -c run_post_zshrc)"
print "caller options untouched: $([[ -o ksh_arrays ]] && print yes || print no)"
EOS
  assert_success
  assert_line "fpath grew by one: 1"
  assert_line "zsh function dirs kept: 1"
  assert_line "precmd registered: 1"
  assert_line "caller options untouched: yes"
}

# The options Zephyr wants are set by the sourced file, so they outlive the function.
@test "the options zephyr-bootstrap sets survive the call" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
print "extendedglob: $([[ -o extended_glob ]] && print on || print off)"
print "interactivecomments: $([[ -o interactive_comments ]] && print on || print off)"
EOS
  assert_success
  assert_line "extendedglob: on"
  assert_line "interactivecomments: on"
}

# The two with real bodies are autoloaded, so they cost nothing until called.
@test "cached-eval and gen-uuid7 are autoloaded, not parsed up front" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
print "cached-eval stub: $(( ${#functions[cached-eval]} < 40 ))"
print "gen-uuid7 stub: $(( ${#functions[gen-uuid7]} < 40 ))"
local -a m=(${(M)fpath:#$ZEPHYR_HOME/functions})
print "in fpath: $#m"
EOS
  assert_success
  assert_line "cached-eval stub: 1"
  assert_line "gen-uuid7 stub: 1"
  assert_line "in fpath: 1"
}

# mkdirvar never worked: it ran a command named P instead of expanding ${(P)var}.
# Nothing called it, and the old test only checked that it was defined.
@test "mkdirvar is gone" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
print "mkdirvar: $+functions[mkdirvar]"
EOS
  assert_success
  assert_line "mkdirvar: 0"
}

# Bundling path:plugins/helper still works, so existing configs do not break.
@test "the helper plugin shim still bootstraps" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/plugins/helper/helper.plugin.zsh
print "bootstrapped: $(zstyle -t ':zephyr:lib:bootstrap' loaded && print yes || print no)"
print "cached-eval: $+functions[cached-eval]"
print "loaded style: $(zstyle -t ':zephyr:plugin:helper' loaded && print yes || print no)"
EOS
  assert_success
  assert_line "bootstrapped: yes"
  assert_line "cached-eval: 1"
  assert_line "loaded style: yes"
}

@test "is-true accepts the truthy spellings and rejects the rest" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
for v in 1 y yes t true o on YES True; do
  is-true $v || print "should be true: $v"
done
for v in 0 n no f false off '' 2 maybe; do
  is-true $v && print "should be false: $v"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "should be"
}

@test "is-callable finds commands, functions, aliases, and builtins" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
function myfunc { }
alias myalias=ls
is-callable myfunc  && print "function: yes"
is-callable myalias && print "alias: yes"
is-callable print   && print "builtin: yes"
is-callable zsh     && print "command: yes"
is-callable nope-not-a-thing || print "missing: no"
EOS
  assert_success
  assert_line "function: yes"
  assert_line "alias: yes"
  assert_line "builtin: yes"
  assert_line "command: yes"
  assert_line "missing: no"
}

@test "gen-uuid7 sets REPLY to a version 7 uuid" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
gen-uuid7 >/dev/null
print "reply: $REPLY"
[[ $REPLY == [0-9a-f](#c8)-[0-9a-f](#c4)-7[0-9a-f](#c3)-[89ab][0-9a-f](#c3)-[0-9a-f](#c12) ]] \
  && print "shape: ok" || print "shape: bad"
EOS
  assert_success
  assert_line "shape: ok"
}

@test "gen-uuid7 values sort in generation order" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
setopt extended_glob
local -a ids
for i in 1 2 3 4 5; do
  gen-uuid7 >/dev/null
  ids+=($REPLY)
done
print "sorted: $([[ "${(j: :)ids}" == "${(j: :)${(o)ids}}" ]] && print yes || print no)"
EOS
  assert_success
  assert_line "sorted: yes"
}

#
# cached-eval
#

@test "cached-eval sources a command's output and caches the file" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
cached-eval print 'export CE=1'
print "CE: $CE"
print "files: ${#$(ls $XDG_CACHE_HOME/zsh/cached-eval)}"
EOS
  assert_success
  assert_line "CE: 1"
}

@test "cached-eval does not re-run the command while the cache is warm" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
stamp=$XDG_CACHE_HOME/runs
: >$stamp
function gen { print "#" >>$stamp; print 'export CE=1' }
cached-eval gen
cached-eval gen
cached-eval gen
print "runs: $(wc -l <$stamp | tr -d ' ')"
EOS
  assert_success
  assert_line "runs: 1"
}

# The cache filename is a hash of the whole command line, so two calls that
# differ only in their arguments do not share a cache.
@test "different arguments get different caches" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
cached-eval print 'export A=1'
cached-eval print 'export B=2'
print "A: $A B: $B"
print "count: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "A: 1 B: 2"
  assert_line "count: 2"
}

# A command that fails part way through used to leave its half-written output
# behind, and every later shell sourced the broken file.
@test "a failing command leaves no cache behind" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
function broken { print 'export HALF=1'; return 1 }
cached-eval broken
print "exit: $?"
print "HALF: ${HALF:-unset}"
print "count: $(ls $XDG_CACHE_HOME/zsh/cached-eval 2>/dev/null | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "exit: 1"
  assert_line "HALF: unset"
  assert_line "count: 0"
}

@test "a failing command leaves no temp files behind" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
setopt extended_glob
cached-eval print 'export OK=1'
function broken { print x; return 1 }
cached-eval broken
print "temps: ${#$(print -l $XDG_CACHE_HOME/zsh/cached-eval/*.[0-9]*(N))}"
EOS
  assert_success
  assert_line "temps: 0"
}

# The cached file is sourced outside `emulate -L`, so a cached `brew shellenv`
# style script can still setopt.
@test "a cached file can set shell options for the caller" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
cached-eval print 'setopt ksh_arrays'
[[ -o ksh_arrays ]] && print "setopt: survived" || print "setopt: lost"
EOS
  assert_success
  assert_line "setopt: survived"
}

@test "cached-eval --clear drops one cache" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
cached-eval print 'export A=1'
cached-eval print 'export B=2'
print "before: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
cached-eval --clear print 'export A=1'
print "after: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "before: 2"
  assert_line "after: 1"
}

@test "a bare cached-eval --clear drops every cache" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
cached-eval print 'export A=1'
cached-eval print 'export B=2'
cached-eval --clear
print "after: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "after: 0"
}

@test "cached-eval with no command line fails" {
  zephyr_zsh 'source $ZEPHYR_HOME/lib/bootstrap.zsh; cached-eval; print "exit: $?"'
  assert_success
  assert_line "exit: 1"
}
