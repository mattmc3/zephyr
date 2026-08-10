#!/usr/bin/env bats
# The compstyle system, and the zephyr completion styles.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

# The setup function is defined on load, but nothing is applied until it runs.
@test "loading defines the setup and help functions" {
  zephyr_plugin compstyle <<'EOS'
print "setup: $+functions[compstyle_zephyr_setup]"
print "help: $+functions[compstyle_zephyr_help]"
print "compstyleinit: $+functions[compstyleinit]"
EOS
  assert_success
  assert_line "setup: 1"
  assert_line "help: 1"
  assert_line "compstyleinit: 1"
}

@test "a dumb terminal turns the plugin off" {
  zephyr_zsh <<'EOS'
export TERM=dumb
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/compstyle/compstyle.plugin.zsh
print "exit: $?"
EOS
  assert_success
  assert_line "exit: 1"
}

# _ignored brings back what ignored-patterns held back, on a second tab, rather
# than leaving those matches hidden for good.
@test "the completer chain escalates through _ignored" {
  zephyr_plugin compstyle <<'EOS'
compstyle_zephyr_setup
zstyle -a ':completion:*' completer reply
print "completer: $reply"
EOS
  assert_success
  assert_line "completer: _complete _ignored _match _approximate"
}

# A guess belongs in the list, never on the line.
@test "approximate and correct keep the original and insert unambiguously" {
  zephyr_plugin compstyle <<'EOS'
compstyle_zephyr_setup
zstyle -s ':completion:*:approximate:foo' original o
print "original: $o"
zstyle -s ':completion:*:correct:foo' insert-unambiguous i
print "insert-unambiguous: $i"
EOS
  assert_success
  assert_line "original: true"
  assert_line "insert-unambiguous: true"
}

# The cache holds compiled state that is only good for the zsh that wrote it, so
# it is versioned the way the compdump already was.
@test "the completion cache path is versioned by zsh version" {
  zephyr_plugin compstyle <<'EOS'
compstyle_zephyr_setup
zstyle -s ':completion::complete:foo' cache-path p
print "path: ${p#$HOME/}"
print "versioned: ${${p##*/zcompcache-}:+yes}"
print "matches: $([[ $p == *zcompcache-$ZSH_VERSION ]] && print yes || print no)"
EOS
  assert_success
  assert_line "versioned: yes"
  assert_line "matches: yes"
}

@test "the hist-complete context uses the history completer" {
  zephyr_plugin compstyle <<'EOS'
compstyle_zephyr_setup
zstyle -a ':completion:hist-complete:foo' completer reply
print "completer: $reply"
EOS
  assert_success
  assert_line "completer: _history"
}

@test "case-insensitive matching is the default" {
  zephyr_plugin compstyle <<'EOS'
compstyle_zephyr_setup
zstyle -a ':completion:*' matcher-list reply
print "first: $reply[1]"
print "caseglob: $([[ -o case_glob ]] && print on || print off)"
EOS
  assert_success
  assert_line "first: m:{a-zA-Z}={A-Za-z}"
  assert_line "caseglob: off"
}

@test "the case-sensitive zstyle drops the case-insensitive matcher" {
  zephyr_plugin compstyle <<'EOS'
zstyle ':zephyr:plugin:compstyle:*' case-sensitive yes
compstyle_zephyr_setup
zstyle -a ':completion:*' matcher-list reply
print "first: $reply[1]"
print "caseglob: $([[ -o case_glob ]] && print on || print off)"
EOS
  assert_success
  assert_line "first: r:|=*"
  assert_line "caseglob: on"
}

@test "compstyle -l lists the available styles" {
  zephyr_plugin compstyle <<'EOS'
compstyleinit
compstyle -l
EOS
  assert_success
  assert_output_contains "zephyr"
}

@test "compstyle rejects an unknown style" {
  zephyr_plugin compstyle <<'EOS'
compstyleinit
compstyle nope-not-a-style
print "exit: $?"
EOS
  assert_success
  assert_output_contains "Completion style not found"
  assert_line "exit: 1"
}

@test "compstyle applies a named style" {
  zephyr_plugin compstyle <<'EOS'
compstyleinit
compstyle zephyr
print "style: $completion_style"
zstyle -a ':completion:*' completer reply
print "completer: $reply"
EOS
  assert_success
  assert_line "style: zephyr"
  assert_line "completer: _complete _ignored _match _approximate"
}

@test "compstyle -h prints help for a style" {
  zephyr_plugin compstyle <<'EOS'
compstyleinit
compstyle -h zephyr
EOS
  assert_success
  assert_output_contains "compstyle zephyr"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:compstyle' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/compstyle/compstyle.plugin.zsh
print "setup: $+functions[compstyle_zephyr_setup]"
EOS
  assert_success
  assert_line "setup: 0"
}
