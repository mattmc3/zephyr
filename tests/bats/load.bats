#!/usr/bin/env bats
# Which plugins zephyr.zsh loads: a list you name, or a preset.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

# Print `name: yes|no` for each plugin named, from the loaded zstyle each one sets.
_loaded_probe() {
  printf '%s\n' \
    'for p in '"$*"'; do' \
    '  zstyle -t ":zephyr:plugin:$p" loaded && print "$p: yes" || print "$p: no"' \
    'done'
}

@test "no plugins and no preset loads the default set" {
  zephyr_zsh "source \$ZEPHYR; $(_loaded_probe editor history prompt confd)"
  assert_success
  assert_line "editor: yes"
  assert_line "history: yes"
  assert_line "prompt: yes"
  assert_line "confd: yes"
}

@test "the default set leaves out the opt-in plugins" {
  zephyr_zsh "source \$ZEPHYR; $(_loaded_probe history-search autosuggest)"
  assert_success
  assert_line "history-search: no"
  assert_line "autosuggest: no"
}

@test "the all preset loads the opt-in plugins too" {
  zephyr_zsh "
zstyle ':zephyr:load' plugins-preset all
source \$ZEPHYR
$(_loaded_probe editor history-search autosuggest confd)"
  assert_success
  assert_line "editor: yes"
  assert_line "history-search: yes"
  assert_line "autosuggest: yes"
  assert_line "confd: yes"
}

@test "the default preset can be asked for by name" {
  zephyr_zsh "
zstyle ':zephyr:load' plugins-preset default
source \$ZEPHYR
$(_loaded_probe editor autosuggest)"
  assert_success
  assert_line "editor: yes"
  assert_line "autosuggest: no"
}

# A hand-picked list is the whole answer: no preset is consulted.
@test "a plugins list wins over a preset" {
  zephyr_zsh "
zstyle ':zephyr:load' plugins environment editor
zstyle ':zephyr:load' plugins-preset all
source \$ZEPHYR
$(_loaded_probe environment editor autosuggest confd)"
  assert_success
  assert_line "environment: yes"
  assert_line "editor: yes"
  assert_line "autosuggest: no"
  assert_line "confd: no"
}

@test "an unknown preset complains and falls back to the default set" {
  zephyr_zsh "
zstyle ':zephyr:load' plugins-preset bogus
source \$ZEPHYR
$(_loaded_probe editor autosuggest)"
  assert_success
  assert_output_contains "zephyr: Unknown plugins-preset 'bogus'."
  assert_line "editor: yes"
  assert_line "autosuggest: no"
}

# The one plugin a preset decides on. Everything else checks its own requirements.
@test "the macos plugin is in a preset only on macOS" {
  zephyr_zsh "
zstyle ':zephyr:load' plugins-preset all
source \$ZEPHYR
[[ \$OSTYPE == darwin* ]] && print 'want: yes' || print 'want: no'
$(_loaded_probe macos)"
  assert_success
  # The two lines agree, whichever platform this is running on.
  want="$(printf '%s\n' "$output" | sed -n 's/^want: //p')"
  assert_line "macos: $want"
}

@test "zephyr.zsh leaves none of its own variables behind" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:load' plugins-preset all
source $ZEPHYR
print "leftovers: ${(k)parameters[(I)_zephyr_*]:-none}"
EOS
  assert_success
  assert_line "leftovers: none"
}

@test "a plugin that does not exist is reported" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:load' plugins environment nosuchplugin
source $ZEPHYR
EOS
  assert_success
  assert_output_contains "zephyr: Plugin not found 'nosuchplugin'."
}

#
# contrib trees
#

_write_plugin() {
  write_file "$TEST_HOME/$1/plugins/$2/$2.plugin.zsh" "typeset -g MARKER_$2='$3'"
}

@test "a qualified name loads from the tree it names" {
  _write_plugin contribs/ohmyzsh git from-omz
  zephyr_zsh "
zstyle ':zephyr:load:contrib' omz \$HOME/contribs/ohmyzsh
zstyle ':zephyr:load' plugins environment omz:git
source \$ZEPHYR
print \"git: \${MARKER_git:-not loaded}\"
print \"environment: \$(zstyle -t :zephyr:plugin:environment loaded && print yes || print no)\""
  assert_success
  assert_line "git: from-omz"
  assert_line "environment: yes"
}

# The whole point: nine of Zephyr's plugin names collide with prezto's modules, so a
# bare name has to stay Zephyr's no matter what a registered tree contains.
@test "a bare name is Zephyr's own even when a contrib tree has that name" {
  _write_plugin contribs/ohmyzsh history from-omz
  zephyr_zsh "
zstyle ':zephyr:load:contrib' omz \$HOME/contribs/ohmyzsh
zstyle ':zephyr:load' plugins history
source \$ZEPHYR
print \"contrib version loaded: \${MARKER_history:-no}\"
print \"histfile set: \${HISTFILE:+yes}\""
  assert_success
  assert_line "contrib version loaded: no"
  assert_line "histfile set: yes"
}

@test "both versions can be loaded, each under its own name" {
  _write_plugin contribs/ohmyzsh history from-omz
  zephyr_zsh "
zstyle ':zephyr:load:contrib' omz \$HOME/contribs/ohmyzsh
zstyle ':zephyr:load' plugins history omz:history
source \$ZEPHYR
print \"contrib version loaded: \${MARKER_history:-no}\"
print \"histfile set: \${HISTFILE:+yes}\""
  assert_success
  assert_line "contrib version loaded: from-omz"
  assert_line "histfile set: yes"
}

# $ZSH_CUSTOM is the one override layer, and it answers bare names only.
@test "ZSH_CUSTOM overrides a built-in plugin" {
  _write_plugin custom editor mine
  zephyr_zsh "
export ZSH_CUSTOM=\$HOME/custom
zstyle ':zephyr:load' plugins editor
source \$ZEPHYR
print \"editor: \$MARKER_editor\"
print \"built-in editor also loaded: \$+functions[bindkey-multiple]\""
  assert_success
  assert_line "editor: mine"
  assert_line "built-in editor also loaded: 0"
}

@test "ZSH_CUSTOM holds plugins Zephyr never had" {
  _write_plugin custom mine from-custom
  zephyr_zsh "
export ZSH_CUSTOM=\$HOME/custom
zstyle ':zephyr:load' plugins mine
source \$ZEPHYR
print \"mine: \$MARKER_mine\""
  assert_success
  assert_line "mine: from-custom"
}

@test "a qualified name does not consult ZSH_CUSTOM" {
  _write_plugin custom git from-custom
  _write_plugin contribs/ohmyzsh git from-omz
  zephyr_zsh "
export ZSH_CUSTOM=\$HOME/custom
zstyle ':zephyr:load:contrib' omz \$HOME/contribs/ohmyzsh
zstyle ':zephyr:load' plugins omz:git
source \$ZEPHYR
print \"git: \$MARKER_git\""
  assert_success
  assert_line "git: from-omz"
}

@test "an unregistered prefix names the trees that are registered" {
  zephyr_zsh "
zstyle ':zephyr:load:contrib' omz \$HOME/one
zstyle ':zephyr:load:contrib' prezto \$HOME/two
zstyle ':zephyr:load' plugins bogus:thing
source \$ZEPHYR"
  assert_success
  assert_output_contains "Unknown contrib 'bogus'"
  assert_output_contains "Registered: omz, prezto"
}

@test "with nothing registered, a qualified name says so" {
  zephyr_zsh "
zstyle ':zephyr:load' plugins omz:git
source \$ZEPHYR"
  assert_success
  assert_output_contains "Unknown contrib 'omz'"
  assert_output_contains "Registered: none"
}

@test "a plugin missing from a registered tree names that tree" {
  zephyr_zsh "
zstyle ':zephyr:load:contrib' omz \$HOME/contribs/ohmyzsh
zstyle ':zephyr:load' plugins omz:nosuch
source \$ZEPHYR"
  assert_success
  assert_output_contains "Plugin not found 'omz:nosuch'"
  assert_output_contains "$TEST_HOME/contribs/ohmyzsh/plugins"
}
