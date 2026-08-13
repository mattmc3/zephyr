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
