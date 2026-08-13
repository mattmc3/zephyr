#!/usr/bin/env bats
# The line is finished from history as you type.

load helpers/common

setup() {
  zephyr_setup
  ZEPHYR_ZLE_PLUGINS="autosuggest"
}
teardown() { zephyr_teardown; }

@test "the widgets and their bindings are set up" {
  zephyr_plugin autosuggest <<'EOS'
print "forward-char: ${widgets[autosuggest-forward-char]:-none}"
print "end-of-line: ${widgets[autosuggest-end-of-line]:-none}"
print "forward-word: ${widgets[autosuggest-forward-word]:-none}"
for km in emacs viins; do
  print "$km: $(bindkey -M $km '^[[C' | awk '{print $2}')"
done
EOS
  assert_success
  assert_line "forward-char: user:autosuggest-forward-char"
  assert_line "end-of-line: user:autosuggest-end-of-line"
  assert_line "forward-word: user:autosuggest-forward-word"
  assert_line "emacs: autosuggest-forward-char"
  assert_line "viins: autosuggest-forward-char"
}

# The plugin has to stand on its own, in any load order. It reads terminfo directly
# rather than borrowing key_info from the editor plugin.
@test "loading it alone does not pull in the editor plugin" {
  zephyr_plugin autosuggest <<'EOS'
zstyle -t ':zephyr:plugin:editor' loaded && print "editor: loaded" || print "editor: not loaded"
print "bindkey-multiple: $+functions[bindkey-multiple]"
print "emacs right: $(bindkey -M emacs '^[[C' | awk '{print $2}')"
EOS
  assert_success
  assert_line "editor: not loaded"
  assert_line "bindkey-multiple: 0"
  assert_line "emacs right: autosuggest-forward-char"
}

@test "skip leaves the take keys at the Zsh defaults" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:autosuggest' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/autosuggest/autosuggest.plugin.zsh
print "widget: $+widgets[autosuggest-forward-char]"
print "emacs right: $(bindkey -M emacs '^[[C' | awk '{print $2}')"
EOS
  assert_success
  assert_line "widget: 0"
  assert_line "emacs right: forward-char"
}

@test "bindkeys no keeps the widgets but binds nothing" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:autosuggest' bindkeys no
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/autosuggest/autosuggest.plugin.zsh
print "widget: $+widgets[autosuggest-forward-char]"
print "emacs right: $(bindkey -M emacs '^[[C' | awk '{print $2}')"
EOS
  assert_success
  assert_line "widget: 1"
  assert_line "emacs right: forward-char"
}

@test "loading through the framework binds the take keys" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:load' plugins environment editor history autosuggest
source $ZEPHYR
run_post_zshrc
print "emacs right: $(bindkey -M emacs '^[[C' | awk '{print $2}')"
print "viins alt-f: $(bindkey -M viins '^[f' | awk '{print $2}')"
EOS
  assert_success
  assert_line "emacs right: autosuggest-forward-char"
  assert_line "viins alt-f: autosuggest-forward-word"
}

#
# Real zle sessions. History seeded by the harness, oldest first:
#   echo one / git status / echo two / git commit -v
#

@test "the suggestion is drawn after the cursor" {
  zephyr_zle <<'EOS'
type-keys 'git'
probe-hl
EOS
  assert_success
  assert_line "1: BUF=[git] CUR=3 PRE=[]"
  assert_line "2: RH=[3 13 fg=8 memo=zephyr-autosuggest]"
}

@test "Right arrow at the end of the line takes the whole suggestion" {
  zephyr_zle <<'EOS'
type-keys 'git'
press right
EOS
  assert_success
  assert_line "2: BUF=[git commit -v] CUR=13 PRE=[]"
}

@test "Alt+F takes one word, Ctrl+E takes the rest" {
  zephyr_zle <<'EOS'
type-keys 'git'
press $'\ef'
press $'\x05'
EOS
  assert_success
  assert_line "2: BUF=[git commit] CUR=10 PRE=[]"
  assert_line "3: BUF=[git commit -v] CUR=13 PRE=[]"
}

@test "Right arrow inside the line still moves the cursor" {
  zephyr_zle <<'EOS'
type-keys 'git'
press left
press right
EOS
  assert_success
  assert_line "2: BUF=[git] CUR=2 PRE=[]"
  assert_line "3: BUF=[git] CUR=3 PRE=[]"
}

@test "a prefix matching nothing suggests nothing" {
  zephyr_zle <<'EOS'
type-keys 'zzz'
probe-hl
press right
EOS
  assert_success
  assert_line "2: RH=[]"
  assert_line "3: BUF=[zzz] CUR=3 PRE=[]"
}

@test "the highlight style is configurable" {
  ZEPHYR_ZLE_RC="$TEST_HOME/rc.zsh"
  write_file "$ZEPHYR_ZLE_RC" \
    "zstyle ':zephyr:plugin:autosuggest' highlight 'fg=blue'"
  zephyr_zle <<'EOS'
type-keys 'git'
probe-hl
EOS
  assert_success
  assert_output_contains "fg=blue memo=zephyr-autosuggest"
}

# A strategy of your own sets $suggestion instead of printing.
@test "a custom strategy replaces the history lookup" {
  ZEPHYR_ZLE_RC="$TEST_HOME/rc.zsh"
  write_file "$ZEPHYR_ZLE_RC" \
    'function my-suggester { suggestion="${1}-from-me" }' \
    "zstyle ':zephyr:plugin:autosuggest' strategy 'my-suggester'"
  zephyr_zle <<'EOS'
type-keys 'zzz'
press right
EOS
  assert_success
  assert_line "2: BUF=[zzz-from-me] CUR=11 PRE=[]"
}

# A stand-in for zsh-syntax-highlighting: appends its own memo-marked spans on every
# redraw. Loaded *after* this plugin, the awkward order, to check our span still ends
# up last, where it wins on overlap.
@test "our span outranks a highlighter loaded after us" {
  ZEPHYR_ZLE_RC="$TEST_HOME/rc.zsh"
  write_file "$ZEPHYR_ZLE_RC" \
    'autoload -Uz add-zle-hook-widget' \
    'function fake-highlighter {' \
    '  region_highlight=(${region_highlight:#*memo=fake-hl})' \
    '  [[ -n $BUFFER ]] && region_highlight+=("0 $#BUFFER fg=green memo=fake-hl")' \
    '}' \
    'add-zle-hook-widget line-pre-redraw fake-highlighter'
  zephyr_zle <<'EOS'
type-keys 'git'
probe-hl
EOS
  assert_success
  assert_output_contains "memo=fake-hl"
  assert_output_contains "fg=8 memo=zephyr-autosuggest]"
}

# Up and Down fill the line themselves and paint their own match, so the suggestion
# steps aside for the duration of a search.
@test "a running history search suppresses the suggestion" {
  ZEPHYR_ZLE_PLUGINS="history-search autosuggest"
  zephyr_zle <<'EOS'
type-keys 'git'
press up
probe-hl
EOS
  assert_success
  assert_output_contains "memo=zephyr-history-search"
  refute_output_contains "memo=zephyr-autosuggest"
}

# The finished line stays on the screen, so the suggestion has to come off it first.
@test "accepting a line leaves the suggestion behind" {
  zephyr_zle <<'EOS'
type-keys 'git'
press enter
type-keys 'zzz'
probe-hl
EOS
  assert_success
  assert_line "2: BUF=[] CUR=0 PRE=[]"
  assert_line "4: RH=[]"
}
