#!/usr/bin/env bats
# History options, file location, and sizes.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the history options are set" {
  zephyr_plugin history <<'EOS'
for opt in bang_hist extended_history hist_expire_dups_first hist_find_no_dups \
           hist_ignore_all_dups hist_ignore_dups hist_ignore_space \
           hist_reduce_blanks hist_save_no_dups hist_verify inc_append_history; do
  [[ -o $opt ]] || print "expected on: $opt"
done
for opt in hist_beep share_history; do
  [[ -o $opt ]] && print "expected off: $opt"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "expected on:"
  refute_output_contains "expected off:"
}

@test "the history file lands in the XDG data dir by default" {
  zephyr_plugin history <<'EOS'
print "histfile: ${HISTFILE#$HOME/}"
[[ -d ${HISTFILE:h} ]] && print "dir: exists" || print "dir: missing"
EOS
  assert_success
  assert_line "histfile: .local/share/zsh/zsh_history"
  assert_line "dir: exists"
}

@test "use-xdg-basedirs no puts the history file in ZDOTDIR" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:history' use-xdg-basedirs no
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history/history.plugin.zsh
print "histfile: ${HISTFILE#$HOME/}"
EOS
  assert_success
  assert_line "histfile: .config/zsh/.zsh_history"
}

@test "a histfile zstyle wins, and expands a leading tilde" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:history' histfile '~/myhist'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history/history.plugin.zsh
print "histfile: ${HISTFILE#$HOME/}"
EOS
  assert_success
  assert_line "histfile: myhist"
}

@test "the sizes get defaults" {
  zephyr_plugin history 'print "SAVEHIST: $SAVEHIST"; print "HISTSIZE: $HISTSIZE"'
  assert_success
  assert_line "SAVEHIST: 100000"
  assert_line "HISTSIZE: 20000"
}

# Zsh always has a value for both, so `zstyle -s ... 'SAVEHIST'` used to empty
# the variable before the fallback ran, clobbering a larger value set earlier.
@test "a larger existing size is left alone" {
  zephyr_zsh <<'EOS'
HISTSIZE=999999 SAVEHIST=888888
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history/history.plugin.zsh
print "SAVEHIST: $SAVEHIST"
print "HISTSIZE: $HISTSIZE"
EOS
  assert_success
  assert_line "SAVEHIST: 888888"
  assert_line "HISTSIZE: 999999"
}

@test "a smaller existing size is raised to the default" {
  zephyr_zsh <<'EOS'
HISTSIZE=5 SAVEHIST=5
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history/history.plugin.zsh
print "SAVEHIST: $SAVEHIST"
print "HISTSIZE: $HISTSIZE"
EOS
  assert_success
  assert_line "SAVEHIST: 100000"
  assert_line "HISTSIZE: 20000"
}

@test "a size zstyle wins outright, even over a larger value" {
  zephyr_zsh <<'EOS'
HISTSIZE=999999 SAVEHIST=999999
zstyle ':zephyr:plugin:history' histsize 42
zstyle ':zephyr:plugin:history' savehist 43
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history/history.plugin.zsh
print "SAVEHIST: $SAVEHIST"
print "HISTSIZE: $HISTSIZE"
EOS
  assert_success
  assert_line "SAVEHIST: 43"
  assert_line "HISTSIZE: 42"
}

@test "the history aliases are set" {
  zephyr_plugin history <<'EOS'
print "hist: $aliases[hist]"
print "histsync: $aliases[histsync]"
print "history-stat: $+aliases[history-stat]"
EOS
  assert_success
  assert_line "hist: fc -li"
  assert_line "histsync: fc -RI"
  assert_line "history-stat: 1"
}

@test "the alias skip zstyle suppresses them" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:history:alias' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history/history.plugin.zsh
print "hist: $+aliases[hist]"
print "histsync: $+aliases[histsync]"
EOS
  assert_success
  assert_line "hist: 0"
  assert_line "histsync: 0"
}
