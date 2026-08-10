#!/usr/bin/env bats
# Environment variables, shell options, and path assembly.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

# Asserted with `[[ -o ... ]]` rather than by grepping `set -o`, which only
# reports options that differ from the Zsh default. Several of these agree with
# the default, so they never show up in that listing and the old test could not
# see them at all.
@test "the shell options are set" {
  zephyr_plugin environment <<'EOS'
for opt in extended_glob combining_chars interactive_comments rc_quotes \
           auto_resume long_list_jobs notify; do
  [[ -o $opt ]] || print "expected on: $opt"
done
for opt in rm_star_silent mail_warning beep bg_nice check_jobs hup; do
  [[ -o $opt ]] && print "expected off: $opt"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "expected on:"
  refute_output_contains "expected off:"
}

@test "the common environment variables get defaults" {
  zephyr_plugin environment <<'EOS'
print "PAGER: $PAGER"
print "LANG: $LANG"
print "LESS: $LESS"
EOS
  assert_success
  assert_line "PAGER: less"
  assert_line "LANG: en_US.UTF-8"
  assert_line "LESS: -g -i -M -R -S -w -z-4"
}

# Zsh presets both of these, so the `${VAR:-default}` and `[[ -n $VAR ]]` guards
# in the plugin never fire and the intended values are never applied. These
# assertions record what actually happens today, not what was meant: KEYTIMEOUT
# stays at Zsh's 40 rather than dropping to 1, and READNULLCMD stays `more`
# rather than following $PAGER.
@test "KEYTIMEOUT and READNULLCMD keep the Zsh preset values" {
  zephyr_plugin environment <<'EOS'
print "KEYTIMEOUT: $KEYTIMEOUT"
print "READNULLCMD: $READNULLCMD"
EOS
  assert_success
  assert_line "KEYTIMEOUT: 40"
  assert_line "READNULLCMD: more"
}

@test "an existing value is never overwritten" {
  zephyr_zsh <<'EOS'
export PAGER=most LANG=fr_FR.UTF-8 KEYTIMEOUT=40 LESS=-X READNULLCMD=bat
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/environment/environment.plugin.zsh
print "PAGER: $PAGER"
print "LANG: $LANG"
print "KEYTIMEOUT: $KEYTIMEOUT"
print "LESS: $LESS"
print "READNULLCMD: $READNULLCMD"
EOS
  assert_success
  assert_line "PAGER: most"
  assert_line "LANG: fr_FR.UTF-8"
  assert_line "KEYTIMEOUT: 40"
  assert_line "LESS: -X"
  assert_line "READNULLCMD: bat"
}

# An empty READNULLCMD is still unset as far as this goes, but a shell where the
# variable exists and holds a value must be left alone.
@test "READNULLCMD is only defaulted when empty" {
  zephyr_zsh <<'EOS'
READNULLCMD=''
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/environment/environment.plugin.zsh
print "READNULLCMD: $READNULLCMD"
EOS
  assert_success
  assert_line "READNULLCMD: less"
}

@test "the XDG base dirs are set and created" {
  zephyr_zsh <<'EOS'
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
zstyle ':zephyr:plugin:environment' use-xdg-basedirs yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/environment/environment.plugin.zsh
print "config: ${XDG_CONFIG_HOME#$HOME/}"
print "state: ${XDG_STATE_HOME#$HOME/}"
[[ -d $XDG_STATE_HOME ]] && print "created: yes" || print "created: no"
EOS
  assert_success
  assert_line "config: .config"
  assert_line "state: .local/state"
  assert_line "created: yes"
}

#
# Paths
#

@test "prepath leads path" {
  zephyr_plugin environment <<'EOS'
print "first: ${path[1]#$HOME/}"
print "prepath: ${${prepath[1]}#$HOME/}"
EOS
  assert_success
  assert_line "first: bin"
  assert_line "prepath: bin"
}

@test "a prepath zstyle replaces the default" {
  zephyr_zsh <<'EOS'
mkdir -p $HOME/custom
zstyle ':zephyr:plugin:environment' prepath "$HOME/custom"
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/environment/environment.plugin.zsh
print "first: ${path[1]#$HOME/}"
EOS
  assert_success
  assert_line "first: custom"
}

@test "path arrays hold no duplicates" {
  zephyr_plugin environment <<'EOS'
path=($HOME/bin $HOME/bin $HOME/bin $path)
prepath=($HOME/bin $HOME/bin)
local -a hits=(${(M)path:#$HOME/bin}) phits=(${(M)prepath:#$HOME/bin})
print "path copies: $#hits"
print "prepath copies: $#phits"
print "prepath type: ${(t)prepath}"
EOS
  assert_success
  assert_line "path copies: 1"
  assert_line "prepath copies: 1"
  assert_line "prepath type: array-unique"
}

# Anything that prepends to path, brew shellenv being the usual culprit, leaves
# user bins behind the additions.
@test "repath puts prepath back at the front" {
  zephyr_plugin environment <<'EOS'
prepath=($HOME/bin)
path=(/opt/added $HOME/bin /usr/bin)
print "before: ${path[1]}"
repath
print "after: ${path[1]#$HOME/}"
print "kept: ${path[2]}"
EOS
  assert_success
  assert_line "before: /opt/added"
  assert_line "after: bin"
  assert_line "kept: /opt/added"
}
