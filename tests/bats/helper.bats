#!/usr/bin/env bats
# Shared helper functions, and the cached-eval cache.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the helper functions are defined" {
  zephyr_plugin helper <<'EOS'
for f in cached-eval is-autoloadable is-callable is-true is-macos is-linux \
         is-bsd is-cygwin is-termux is-term-family is-tmux gen-uuid7 mkdirvar; do
  (( $+functions[$f] )) || print "missing: $f"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

@test "is-true accepts the truthy spellings and rejects the rest" {
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
gen-uuid7 >/dev/null
print "reply: $REPLY"
[[ $REPLY == [0-9a-f](#c8)-[0-9a-f](#c4)-7[0-9a-f](#c3)-[89ab][0-9a-f](#c3)-[0-9a-f](#c12) ]] \
  && print "shape: ok" || print "shape: bad"
EOS
  assert_success
  assert_line "shape: ok"
}

@test "gen-uuid7 values sort in generation order" {
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
cached-eval print 'export CE=1'
print "CE: $CE"
print "files: ${#$(ls $XDG_CACHE_HOME/zsh/cached-eval)}"
EOS
  assert_success
  assert_line "CE: 1"
}

@test "cached-eval does not re-run the command while the cache is warm" {
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
cached-eval print 'setopt ksh_arrays'
[[ -o ksh_arrays ]] && print "setopt: survived" || print "setopt: lost"
EOS
  assert_success
  assert_line "setopt: survived"
}

@test "cached-eval --clear drops one cache" {
  zephyr_plugin helper <<'EOS'
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
  zephyr_plugin helper <<'EOS'
cached-eval print 'export A=1'
cached-eval print 'export B=2'
cached-eval --clear
print "after: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "after: 0"
}

@test "cached-eval with no command line fails" {
  zephyr_plugin helper 'cached-eval; print "exit: $?"'
  assert_success
  assert_line "exit: 1"
}
