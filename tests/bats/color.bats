#!/usr/bin/env bats
# Color aliases are built on top of whatever the user already set.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the colors function and man page colors are set" {
  zephyr_plugin color <<'EOS'
print "colors: $+functions[colors]"
print "md-has-bold-blue: ${${LESS_TERMCAP_md#*\[}:+${${(M)LESS_TERMCAP_md#*01;34m}:+yes}}"
print "se-set: ${LESS_TERMCAP_se:+yes}"
EOS
  assert_success
  assert_line "colors: 1"
  assert_line "md-has-bold-blue: yes"
  assert_line "se-set: yes"
}

@test "a dumb terminal turns the plugin off" {
  zephyr_zsh <<'EOS'
export TERM=dumb
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "exit: $?"
print "loaded: $(zstyle -t ':zephyr:plugin:color' loaded && print yes || print no)"
EOS
  assert_success
  assert_line "exit: 1"
  assert_line "loaded: no"
}

@test "color aliases compose onto an existing alias" {
  stub_command dircolors 'print "export LS_COLORS=di=34:"'
  zephyr_zsh <<'EOS'
alias ls='eza'
alias grep='rg'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "ls: $aliases[ls]"
print "grep: $aliases[grep]"
EOS
  assert_success
  assert_line "ls: eza --color=auto"
  assert_line "grep: rg --color=auto"
}

@test "sourcing the plugin twice does not append --color twice" {
  stub_command dircolors 'print "export LS_COLORS=di=34:"'
  zephyr_zsh <<'EOS'
alias ls='eza'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "ls: $aliases[ls]"
print "grep: $aliases[grep]"
EOS
  assert_success
  assert_line "ls: eza --color=auto"
  assert_line "grep: grep --color=auto"
}

@test "an existing color choice is left alone" {
  stub_command dircolors 'print "export LS_COLORS=di=34:"'
  zephyr_zsh <<'EOS'
alias ls='eza --color=always'
alias grep='grep --color=never'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "ls: $aliases[ls]"
print "grep: $aliases[grep]"
EOS
  assert_success
  assert_line "ls: eza --color=always"
  assert_line "grep: grep --color=never"
}

# GNU ls colorizes with --color, BSD ls with -G, and an old BSD ls dies on
# --color rather than ignoring it. dircolors ships with GNU coreutils, so having
# it stands in for "this is GNU" without paying for a probe. Both branches are
# forced here, so the assertions hold on whichever platform runs the tests.
@test "ls gets --color=auto where dircolors exists" {
  stub_command dircolors 'print "export LS_COLORS=di=34:"'
  zephyr_plugin color 'print "ls: $aliases[ls]"'
  assert_success
  assert_line "ls: ls --color=auto"
}

# $path is narrowed to the stub dir so dircolors is genuinely absent whatever the
# host has installed. Only builtins are used past that point.
@test "ls gets -G where dircolors is missing" {
  zephyr_zsh <<'EOS'
path=($HOME/bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "ls: $aliases[ls]"
EOS
  assert_success
  assert_line "ls: ls -G"
}

# -G is BSD ls's own spelling and says nothing about a replacement someone
# aliased in: eza reads -G as --grid.
@test "an aliased-in ls replacement gets --color=auto, not -G" {
  zephyr_zsh <<'EOS'
path=($HOME/bin); rehash
alias ls='eza'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "ls: $aliases[ls]"
EOS
  assert_success
  assert_line "ls: eza --color=auto"
}

@test "LSCOLORS and CLICOLOR are set where dircolors is missing" {
  zephyr_zsh <<'EOS'
path=($HOME/bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "CLICOLOR: $CLICOLOR"
print "LSCOLORS: $LSCOLORS"
EOS
  assert_success
  assert_line "CLICOLOR: 1"
  assert_line "LSCOLORS: exfxcxdxbxGxDxabagacad"
}

@test "LS_COLORS comes from dircolors when it is available" {
  stub_command dircolors 'print "export LS_COLORS=di=99:"'
  zephyr_plugin color 'print "LS_COLORS: $LS_COLORS"'
  assert_success
  assert_line "LS_COLORS: di=99:"
}

@test "an existing LS_COLORS is not replaced" {
  stub_command dircolors 'print "export LS_COLORS=di=99:"'
  zephyr_zsh <<'EOS'
export LS_COLORS='di=11:'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "LS_COLORS: $LS_COLORS"
EOS
  assert_success
  assert_line "LS_COLORS: di=11:"
}

@test "LS_COLORS falls back to a built-in default" {
  zephyr_zsh <<'EOS'
path=($HOME/bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "LS_COLORS: $LS_COLORS"
EOS
  assert_success
  assert_output_contains "di=34:ln=35:so=32"
}

#
# diff. Old BSD diff has no --color, and asking costs a fork, so the question is
# deferred to the first call.
#

@test "diff starts as a function, not an alias" {
  zephyr_plugin color <<'EOS'
print "func: $+functions[diff]"
print "alias: $+aliases[diff]"
EOS
  assert_success
  assert_line "func: 1"
  assert_line "alias: 0"
}

@test "a diff that understands --color becomes an alias on first use" {
  stub_command diff 'exit 0'
  zephyr_plugin color <<'EOS'
diff /dev/null /dev/null
print "func: $+functions[diff]"
print "alias: $aliases[diff]"
EOS
  assert_success
  assert_line "func: 0"
  assert_line "alias: diff --color"
}

@test "a diff without --color leaves no alias behind" {
  stub_command diff '[[ "$1" == --color ]] && exit 2; exit 0'
  zephyr_plugin color <<'EOS'
diff /dev/null /dev/null
print "func: $+functions[diff]"
print "alias: $+aliases[diff]"
EOS
  assert_success
  assert_line "func: 0"
  assert_line "alias: 0"
}

@test "an existing diff alias is extended rather than replaced" {
  stub_command diff 'exit 0'
  zephyr_zsh <<'EOS'
alias diff='diff -u'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "alias: $aliases[diff]"
print "func: $+functions[diff]"
EOS
  assert_success
  assert_line "alias: diff -u --color"
  assert_line "func: 0"
}

@test "the alias skip zstyle suppresses the color aliases" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:color:alias' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "ls: $+aliases[ls]"
print "grep: $+aliases[grep]"
print "diff func: $+functions[diff]"
print "colormap: $+aliases[colormap]"
EOS
  assert_success
  assert_line "ls: 0"
  assert_line "grep: 0"
  assert_line "diff func: 0"
  assert_line "colormap: 0"
}

@test "the cache zstyle routes dircolors through cached-eval" {
  stub_command dircolors 'print "export LS_COLORS=di=77:"'
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:color' use-cache yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
print "LS_COLORS: $LS_COLORS"
print "cached: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "LS_COLORS: di=77:"
  assert_line "cached: 1"
}
