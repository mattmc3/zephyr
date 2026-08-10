#!/usr/bin/env bats
# Up and Down search history for the text already on the line.

load helpers/common

setup() {
  zephyr_setup
  ZEPHYR_ZLE_PLUGINS="history-search"
}
teardown() { zephyr_teardown; }

@test "the widgets and their bindings are set up" {
  zephyr_plugin history-search <<'EOS'
print "up: ${widgets[up-line-or-history-search]:-none}"
print "down: ${widgets[down-line-or-history-search]:-none}"
for km in emacs viins vicmd; do
  print "$km: $(bindkey -M $km '^[[A' | awk '{print $2}')"
done
EOS
  assert_success
  assert_line "up: user:up-line-or-history-search"
  assert_line "down: user:down-line-or-history-search"
  assert_line "emacs: up-line-or-history-search"
  assert_line "viins: up-line-or-history-search"
  assert_line "vicmd: up-line-or-history-search"
}

# The plugin has to stand on its own, in any load order. It reads terminfo
# directly rather than borrowing key_info from the editor plugin.
@test "loading it alone does not pull in the editor plugin" {
  zephyr_plugin history-search <<'EOS'
zstyle -t ':zephyr:plugin:editor' loaded && print "editor: loaded" || print "editor: not loaded"
print "bindkey-multiple: $+functions[bindkey-multiple]"
print "emacs up: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
EOS
  assert_success
  assert_line "editor: not loaded"
  assert_line "bindkey-multiple: 0"
  assert_line "emacs up: up-line-or-history-search"
}

@test "skip leaves Up and Down at the Zsh defaults" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:history-search' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history-search/history-search.plugin.zsh
print "up widget: $+widgets[up-line-or-history-search]"
print "emacs up: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
EOS
  assert_success
  assert_line "up widget: 0"
  assert_line "emacs up: up-line-or-history"
}

@test "bindkeys no keeps the widgets but binds nothing" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:history-search' bindkeys no
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history-search/history-search.plugin.zsh
print "up widget: $+widgets[up-line-or-history-search]"
print "emacs up: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
EOS
  assert_success
  assert_line "up widget: 1"
  assert_line "emacs up: up-line-or-history"
}

# The editor plugin used to run `bindkey -d` unconditionally, which wiped these
# bindings whenever it loaded second. It no longer resets by default, so the
# bindings survive either load order and no repair pass is needed.
@test "the editor plugin loading afterwards leaves the bindings alone" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history-search/history-search.plugin.zsh
print "after load: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "after editor: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
EOS
  assert_success
  assert_line "after load: up-line-or-history-search"
  assert_line "after editor: up-line-or-history-search"
}

# Asking the editor plugin to reset keymaps still costs these bindings, which is one
# reason that option is opt-in. Re-bind by hand, or load this plugin after the editor.
@test "the editor reset-keymaps option does clobber them" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' reset-keymaps yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/history-search/history-search.plugin.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "after reset: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
history-search-bindkeys
print "after re-bind: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
EOS
  assert_success
  assert_line "after reset: up-line-or-history"
  assert_line "after re-bind: up-line-or-history-search"
}

# Loaded through zephyr.zsh rather than sourced directly, alongside the editor
# plugin. The load list is given explicitly, so this does not depend on the plugin
# being in zephyr.zsh's defaults.
@test "loading through the framework binds the search widgets" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:load' plugins environment editor history history-search
source $ZEPHYR
run_post_zshrc
print "emacs up: $(bindkey -M emacs '^[[A' | awk '{print $2}')"
print "vicmd down: $(bindkey -M vicmd '^[[B' | awk '{print $2}')"
EOS
  assert_success
  assert_line "emacs up: up-line-or-history-search"
  assert_line "vicmd down: down-line-or-history-search"
}

#
# Real zle sessions. History seeded by the harness, oldest first:
#   echo one / git status / echo two / git commit -v
#

@test "Up walks back through matching history entries" {
  zephyr_zle <<'EOS'
type-keys 'git'
press up
press up
EOS
  assert_success
  assert_line "1: BUF=[git] CUR=3 PRE=[]"
  assert_line "2: BUF=[git commit -v] CUR=13 PRE=[]"
  assert_line "3: BUF=[git status] CUR=10 PRE=[]"
}

@test "Up stops at the oldest match instead of wrapping" {
  zephyr_zle <<'EOS'
type-keys 'git'
press up
press up
press up
EOS
  assert_success
  assert_line "3: BUF=[git status] CUR=10 PRE=[]"
  assert_line "4: BUF=[git status] CUR=10 PRE=[]"
}

@test "Down past the newest match restores the typed line" {
  zephyr_zle <<'EOS'
type-keys 'git'
press up
press down
EOS
  assert_success
  assert_line "2: BUF=[git commit -v] CUR=13 PRE=[]"
  assert_line "3: BUF=[git] CUR=3 PRE=[]"
}

@test "a non-matching prefix leaves the line alone" {
  zephyr_zle <<'EOS'
type-keys 'zzz'
press up
EOS
  assert_success
  assert_line "1: BUF=[zzz] CUR=3 PRE=[]"
  assert_line "2: BUF=[zzz] CUR=3 PRE=[]"
}

@test "the matched substring is highlighted" {
  zephyr_zle <<'EOS'
type-keys 'git'
press up
probe-hl
EOS
  assert_success
  assert_output_contains "standout memo=zephyr-history-search"
}

# A stand-in for zsh-syntax-highlighting: appends its own memo-marked spans on every
# redraw, which is the behavior that matters here. Loaded *after* this plugin, the
# awkward order, to check our span still ends up last, where it wins on overlap.
# Verified against the real highlighter too, which produces the same ordering.
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
press up
probe-hl
EOS
  assert_success
  # Both spans present, ours last.
  assert_output_contains "memo=fake-hl"
  assert_output_contains "standout memo=zephyr-history-search]"
}

# hss carries a timeout hack to stop its highlight lingering once a search ends. Ours
# is removed by the same redraw hook that drew it, and the highlighter's spans are
# left untouched.
@test "ending the search removes only our span" {
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
press up
type-keys 'X'
probe-hl
EOS
  assert_success
  refute_output_contains "memo=zephyr-history-search"
  assert_output_contains "memo=fake-hl"
}

@test "editing the line ends the search, and unpaints the match" {
  zephyr_zle <<'EOS'
type-keys 'git'
press up
type-keys 'X'
probe-hl
EOS
  assert_success
  assert_line "2: BUF=[git commit -v] CUR=13 PRE=[]"
  assert_line "3: BUF=[git commit -vX] CUR=14 PRE=[]"
  assert_line "4: RH=[]"
}
