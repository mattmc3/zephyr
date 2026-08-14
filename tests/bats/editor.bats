#!/usr/bin/env bats
# Line editor widgets, keymaps, and the accept-line hooks.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the editor options and variables are set" {
  zephyr_plugin editor <<'EOS'
print "nobeep: $([[ -o beep ]] && print off || print on)"
print "noflowcontrol: $([[ -o flow_control ]] && print off || print on)"
print "wordchars: $WORDCHARS"
print "key_info: $+parameters[key_info]"
EOS
  assert_success
  assert_line "nobeep: on"
  assert_line "noflowcontrol: on"
  assert_line 'wordchars: *?_-.[]~&;!#$%^(){}<>'
  assert_line "key_info: 1"
}

@test "the wordchars zstyle overrides the default" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' wordchars '*?_-'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "wordchars: $WORDCHARS"
EOS
  assert_success
  assert_line "wordchars: *?_-"
}

@test "a dumb terminal turns the plugin off" {
  zephyr_zsh <<'EOS'
export TERM=dumb
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "exit: $?"
EOS
  assert_success
  assert_line "exit: 1"
}

@test "the widgets are defined" {
  zephyr_plugin editor <<'EOS'
for w in update-cursor-style zle-line-init zle-line-finish zle-keymap-select \
         dot-expansion prepend-sudo glob-alias pound-toggle symmetric-ctrl-z \
         copybuffer edit-command-line hist-complete accept-line-or-newline; do
  (( $+widgets[$w] )) || print "missing: $w"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

@test "the helper functions are defined" {
  zephyr_plugin editor <<'EOS'
for f in bindkey-all bindkey-multiple add-accept-line-hook run-accept-line-hooks \
         command-is-complete magic-enter magic-enter-cmd; do
  (( $+functions[$f] )) || print "missing: $f"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "missing:"
}

#
# Keymaps and bindings
#

@test "the keymap is emacs by default" {
  zephyr_plugin editor 'bindkey -lL main'
  assert_success
  assert_line "bindkey -A emacs main"
}

@test "the key-bindings zstyle selects vi" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings vi
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
bindkey -lL main
EOS
  assert_success
  assert_line "bindkey -A viins main"
}

# `existing` is for people who ran `bindkey -v` themselves, or load something like
# zsh-vi-mode: the plugin binds its keys but leaves the choice of keymap alone.
@test "key-bindings existing leaves a vi choice alone" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings existing
bindkey -v
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
bindkey -lL main
print "layout: $_zph_editor_layout"
EOS
  assert_success
  assert_line "bindkey -A viins main"
  assert_line "layout: vi"
}

@test "key-bindings existing leaves an emacs choice alone" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings existing
bindkey -e
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
bindkey -lL main
print "layout: $_zph_editor_layout"
EOS
  assert_success
  assert_line "bindkey -A emacs main"
  assert_line "layout: emacs"
}

# Choosing emacs or vi outright orphans a binding made beforehand with a bare
# `bindkey`: it stays in the keymap it landed in, which main no longer points at.
@test "key-bindings existing keeps earlier bare bindkeys reachable" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings existing
bindkey -v
bindkey '^Y' beep
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "reachable: $(bindkey '^Y' | awk '{print $2}')"
EOS
  assert_success
  assert_line "reachable: beep"
}

@test "choosing emacs orphans an earlier vi-mode bare bindkey" {
  zephyr_zsh <<'EOS'
bindkey -v
bindkey '^Y' beep
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "main: $(bindkey '^Y' | awk '{print $2}')"
print "still in viins: $(bindkey -M viins '^Y' | awk '{print $2}')"
EOS
  assert_success
  assert_line "main: yank"
  assert_line "still in viins: beep"
}

# The cursor styles are named for the mode, so under `existing` the layout has to be
# resolved from what is actually linked rather than assumed to be emacs.
@test "the cursor follows the resolved layout under existing" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings existing
zstyle ':zephyr:plugin:editor:viins' cursor underscore-blink
bindkey -v
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
printf 'viins: '; KEYMAP=main update-cursor-style | cat -v; print
EOS
  assert_success
  assert_line 'viins: ^[[3 q'
}

@test "an invalid key-bindings value complains" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings nonsense
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
EOS
  assert_success
  assert_output_contains "invalid key bindings"
}

@test "the Ctrl-X bindings land in every keymap" {
  zephyr_plugin editor <<'EOS'
for km in emacs viins vicmd; do
  print "$km e: $(bindkey -M $km '^X^E' | awk '{print $2}')"
  print "$km x: $(bindkey -M $km '^X^X' | awk '{print $2}')"
  print "$km c: $(bindkey -M $km '^X^C' | awk '{print $2}')"
done
EOS
  assert_success
  assert_line "emacs e: edit-command-line"
  assert_line "emacs x: hist-complete"
  assert_line "emacs c: copybuffer"
  assert_line "vicmd e: edit-command-line"
  assert_line "vicmd c: copybuffer"
}

@test "prepend-sudo and pound-toggle are bound" {
  zephyr_plugin editor <<'EOS'
print "sudo: $(bindkey -M emacs '^X^S' | awk '{print $2}')"
print "pound: $(bindkey -M emacs '^[;' | awk '{print $2}')"
print "vipound: $(bindkey -M vicmd '#' | awk '{print $2}')"
EOS
  assert_success
  assert_line "sudo: prepend-sudo"
  assert_line "pound: pound-toggle"
  assert_line "vipound: vi-pound-insert"
}

@test "an opt-out feature can be turned off" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' prepend-sudo no
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "sudo: $(bindkey -M emacs '^X^S' | awk '{print $2}')"
EOS
  assert_success
  assert_line "sudo: undefined-key"
}

@test "dot-expansion is opt-in" {
  zephyr_plugin editor 'print "dot: $(bindkey -M emacs "." | awk "{print \$2}")"'
  assert_success
  assert_line "dot: self-insert"

  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' dot-expansion yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "dot: $(bindkey -M emacs '.' | awk '{print $2}')"
EOS
  assert_success
  assert_line "dot: dot-expansion"
}

# Resetting keymaps is off by default: it discards bindings made before the plugin
# loads, and deleting keymaps from a deferred call segfaults Zsh (issue #40).
@test "keymaps are not reset by default" {
  zephyr_zsh <<'EOS'
bindkey -N mycustom
bindkey -M emacs '^Y' beep
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "earlier binding: $(bindkey -M emacs '^Y' | awk '{print $2}')"
print "custom keymap: $(bindkey -l | grep -c mycustom)"
EOS
  assert_success
  assert_line "earlier binding: beep"
  assert_line "custom keymap: 1"
}

@test "reset-keymaps restores the defaults and drops custom keymaps" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' reset-keymaps yes
bindkey -N mycustom
bindkey -M emacs '^A' beep
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "clobbered default: $(bindkey -M emacs '^A' | awk '{print $2}')"
print "custom keymap: $(bindkey -l | grep -c mycustom)"
EOS
  assert_success
  assert_line "clobbered default: beginning-of-line"
  assert_line "custom keymap: 0"
}

# Deleting keymaps from a deferred call segfaults Zsh, so the reset is skipped when
# zsh-defer is in play even if it was asked for.
@test "reset-keymaps is skipped under zsh-defer" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' reset-keymaps yes
typeset -ga zsh_defer_options=()
bindkey -M emacs '^A' beep
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "left alone: $(bindkey -M emacs '^A' | awk '{print $2}')"
EOS
  assert_success
  assert_line "left alone: beep"
}

@test "bindkey-multiple skips sequences the terminal does not report" {
  zephyr_plugin editor <<'EOS'
bindkey-multiple -M emacs beep '' '^X^Q' ''
print "bound: $(bindkey -M emacs '^X^Q' | awk '{print $2}')"
EOS
  assert_success
  assert_line "bound: beep"
}

#
# Cursor styles
#

@test "the cursor defaults to a line in insert mode and a block in vicmd" {
  zephyr_plugin editor <<'EOS'
printf 'emacs: '; KEYMAP=main update-cursor-style | cat -v; print
printf 'vicmd: '; KEYMAP=vicmd update-cursor-style | cat -v; print
EOS
  assert_success
  assert_line 'emacs: ^[[6 q'
  assert_line 'vicmd: ^[[2 q'
}

@test "the cursor styles include the blinking variants" {
  zephyr_plugin editor <<'EOS'
for style in block block-blink underscore underscore-blink line line-blink; do
  zstyle ":zephyr:plugin:editor:emacs" cursor $style
  printf '%s: ' $style; KEYMAP=main update-cursor-style | cat -v; print
done
EOS
  assert_success
  assert_line 'block-blink: ^[[1 q'
  assert_line 'block: ^[[2 q'
  assert_line 'underscore-blink: ^[[3 q'
  assert_line 'underscore: ^[[4 q'
  assert_line 'line-blink: ^[[5 q'
  assert_line 'line: ^[[6 q'
}

# zle reports insert mode as `main`, so the mode is resolved from the layout to
# make the per-mode styles readable.
@test "main resolves to viins under vi bindings" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' key-bindings vi
zstyle ':zephyr:plugin:editor:viins' cursor underscore-blink
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
printf 'viins: '; KEYMAP=main update-cursor-style | cat -v; print
EOS
  assert_success
  assert_line 'viins: ^[[3 q'
}

#
# Alias expansion. A global alias always expands; a plain one only when it is not
# also a command name, so ls='ls --color' is left alone.
#

@test "glob-alias leaves an alias that is also a command alone" {
  zephyr_plugin editor <<'EOS'
function zle { [[ "$1" == _expand_alias ]] && print -n EXPAND }
alias ls='ls --color=auto'
LBUFFER='ls'; glob-alias; print
EOS
  assert_success
  refute_output_contains "EXPAND"
}

@test "glob-alias expands an alias that is not a command" {
  zephyr_plugin editor <<'EOS'
function zle { [[ "$1" == _expand_alias ]] && print -n EXPAND }
alias gs='git status'
LBUFFER='gs'; glob-alias; print
EOS
  assert_success
  assert_output_contains "EXPAND"
}

@test "glob-alias always expands a global alias" {
  zephyr_plugin editor <<'EOS'
function zle { [[ "$1" == _expand_alias ]] && print -n EXPAND }
alias -g GG='| grep'
LBUFFER='GG'; glob-alias; print
EOS
  assert_success
  assert_output_contains "EXPAND"
}

@test "the noexpand list wins over everything" {
  zephyr_plugin editor <<'EOS'
function zle { [[ "$1" == _expand_alias ]] && print -n EXPAND }
zstyle ':zephyr:plugin:editor:glob-alias' noexpand gs GG
alias gs='git status'
alias -g GG='| grep'
LBUFFER='gs'; glob-alias; print
LBUFFER='GG'; glob-alias; print
EOS
  assert_success
  refute_output_contains "EXPAND"
}

@test "the expand list forces a command-name alias" {
  zephyr_plugin editor <<'EOS'
function zle { [[ "$1" == _expand_alias ]] && print -n EXPAND }
zstyle ':zephyr:plugin:editor:glob-alias' expand ls
alias ls='ls --color=auto'
LBUFFER='ls'; glob-alias; print
EOS
  assert_success
  assert_output_contains "EXPAND"
}

# glob-alias-word is the decision, without the keypress. Splitting them lets the same
# logic run as an accept-line hook, where inserting a character would be wrong.
@test "glob-alias-word expands without inserting a character" {
  zephyr_plugin editor <<'EOS'
function zle { print -n "[$1]" }
alias gs='git status'
LBUFFER='gs'; glob-alias-word; print
EOS
  assert_success
  assert_line "[_expand_alias]"
}

@test "glob-alias expands and then inserts the key" {
  zephyr_plugin editor <<'EOS'
function zle { print -n "[$1]" }
alias gs='git status'
LBUFFER='gs'; glob-alias; print
EOS
  assert_success
  assert_line "[_expand_alias][self-insert]"
}

# Expanding on Enter rewrites the line about to run, so it is opt-in.
@test "expanding on accept-line is off by default and opt-in" {
  zephyr_plugin editor 'print "hooks: ${accept_line_hook:-none}"'
  assert_success
  assert_line "hooks: none"

  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor:glob-alias' on-accept yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "hooks: $accept_line_hook"
EOS
  assert_success
  assert_line "hooks: glob-alias-word"
}

#
# accept-line hooks
#

@test "accept-line is wrapped once, and re-sourcing does not wrap the wrapper" {
  zephyr_plugin editor <<'EOS'
print "widget: $widgets[accept-line]"
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "again: $widgets[accept-line]"
EOS
  assert_success
  assert_line "widget: user:accept-line-with-hooks"
  assert_line "again: user:accept-line-with-hooks"
}

@test "add-accept-line-hook adds, dedupes, and detaches" {
  zephyr_plugin editor <<'EOS'
add-accept-line-hook one
print "after one: $accept_line_hook"
add-accept-line-hook two
print "after two: $accept_line_hook"
add-accept-line-hook one
print "no dupe: $accept_line_hook"
add-accept-line-hook -d one
print "after detach: $accept_line_hook"
EOS
  assert_success
  assert_line "after one: one"
  assert_line "after two: one two"
  assert_line "no dupe: one two"
  assert_line "after detach: two"
}

# The list and the register function live in lib/bootstrap.zsh, so a plugin can
# register before the editor plugin loads, or without it at all.
@test "a hook can be registered before the editor plugin loads" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
print "api without editor: $+functions[add-accept-line-hook]"
add-accept-line-hook early-bird
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "kept: $accept_line_hook"
print "wrapper: $widgets[accept-line]"
EOS
  assert_success
  assert_line "api without editor: 1"
  assert_line "kept: early-bird"
  assert_line "wrapper: user:accept-line-with-hooks"
}

@test "hooks run in the order added, and a missing one is skipped" {
  zephyr_plugin editor <<'EOS'
function first { print "first ran" }
function second { print "second ran" }
add-accept-line-hook first gone-away second
run-accept-line-hooks
print "exit: $?"
EOS
  assert_success
  assert_line "first ran"
  assert_line "second ran"
  assert_line "exit: 0"
}

@test "magic-enter registers as a hook when enabled" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' magic-enter yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "hooks: $accept_line_hook"
EOS
  assert_success
  assert_line "hooks: magic-enter"
}

@test "magic-enter is not registered by default" {
  zephyr_plugin editor 'print "hooks: ${accept_line_hook:-none}"'
  assert_success
  assert_line "hooks: none"
}

@test "magic-enter-cmd falls back to ls outside a repo" {
  zephyr_plugin editor <<'EOS'
cd $HOME
print "cmd: $(magic-enter-cmd)"
EOS
  assert_success
  assert_line "cmd: ls ."
}

@test "magic-enter-cmd uses the git command inside a work tree" {
  zephyr_plugin editor <<'EOS'
cd $HOME && git init -q repo && cd repo
print "cmd: $(magic-enter-cmd)"
EOS
  assert_success
  assert_line "cmd: git status -sb ."
}

# jj is checked before git, so a colocated repo gets the jj command. There is no
# default, so nothing is spent on jj unless the style is set.
@test "the jj command wins inside a jj repo" {
  stub_command jj 'exit 0'
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor:magic-enter' jj-command 'jj st'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
cd $HOME && git init -q repo2 && cd repo2
print "cmd: $(magic-enter-cmd)"
EOS
  assert_success
  assert_line "cmd: jj st"
}

@test "jj is not consulted without the style" {
  stub_command jj 'print "JJ RAN" >&2; exit 0'
  zephyr_plugin editor <<'EOS'
cd $HOME
print "cmd: $(magic-enter-cmd)"
EOS
  assert_success
  assert_line "cmd: ls ."
  refute_output_contains "JJ RAN"
}

@test "the magic-enter command zstyles are honored" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor:magic-enter' command 'ls -la'
zstyle ':zephyr:plugin:editor:magic-enter' git-command 'git status'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
cd $HOME
print "plain: $(magic-enter-cmd)"
cd $HOME && git init -q repo3 && cd repo3
print "git: $(magic-enter-cmd)"
EOS
  assert_success
  assert_line "plain: ls -la"
  assert_line "git: git status"
}

#
# command-is-complete decides whether Enter runs the line or opens a new one.
#

@test "a finished command is complete" {
  zephyr_plugin editor <<'EOS'
for c in 'echo hi' 'if true; then echo; fi' 'for x in 1 2; do echo $x; done' \
         'function foo { echo bar }' '' 'echo "quoted string"'; do
  command-is-complete "$c" && print "complete: [$c]" || print "incomplete: [$c]"
done
EOS
  assert_success
  assert_line "complete: [echo hi]"
  assert_line "complete: [if true; then echo; fi]"
  assert_line "complete: [for x in 1 2; do echo \$x; done]"
  assert_line "complete: [function foo { echo bar }]"
  assert_line "complete: [echo \"quoted string\"]"
}

@test "an unfinished command is incomplete" {
  zephyr_plugin editor <<'EOS'
command-is-complete 'for x in 1 2' && print "for: complete" || print "for: incomplete"
command-is-complete 'if true; then' && print "if: complete" || print "if: incomplete"
command-is-complete 'echo "open' && print "quote: complete" || print "quote: incomplete"
command-is-complete 'cat <<END' && print "heredoc: complete" || print "heredoc: incomplete"
command-is-complete 'echo \' && print "backslash: complete" || print "backslash: incomplete"
EOS
  assert_success
  assert_line "for: incomplete"
  assert_line "if: incomplete"
  assert_line "quote: incomplete"
  assert_line "heredoc: incomplete"
  assert_line "backslash: incomplete"
}

# An even number of trailing backslashes is a literal backslash, not a
# continuation.
@test "trailing backslashes are counted" {
  zephyr_plugin editor <<'EOS'
command-is-complete 'echo a\\' && print "two: complete" || print "two: incomplete"
command-is-complete 'echo a\\\' && print "three: complete" || print "three: incomplete"
EOS
  assert_success
  assert_line "two: complete"
  assert_line "three: incomplete"
}

@test "accept-line-or-newline is bound only when opted in" {
  zephyr_plugin editor 'print "enter: $(bindkey -M emacs "^M" | awk "{print \$2}")"'
  assert_success
  assert_line "enter: accept-line"

  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' accept-line-or-newline yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "enter: $(bindkey -M emacs '^M' | awk '{print $2}')"
print "ctrlj: $(bindkey -M emacs '^J' | awk '{print $2}')"
EOS
  assert_success
  assert_line "enter: accept-line-or-newline"
  assert_line "ctrlj: accept-line-or-newline"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:editor' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh
print "bindkey-all: $+functions[bindkey-all]"
print "key_info: $+parameters[key_info]"
EOS
  assert_success
  assert_line "bindkey-all: 0"
  assert_line "key_info: 0"
}

#
# Real zle sessions.
#

@test "prepend-sudo puts sudo at the front of the line" {
  zephyr_zle <<'EOS'
type-keys 'rm -rf /tmp/x'
press $'\x18\x13'
EOS
  assert_success
  assert_line "1: BUF=[rm -rf /tmp/x] CUR=13 PRE=[]"
  assert_line "2: BUF=[sudo rm -rf /tmp/x] CUR=18 PRE=[]"
}

@test "pound-toggle comments and uncomments the line" {
  zephyr_zle <<'EOS'
type-keys 'echo hi'
press $'\e;'
press $'\e;'
EOS
  assert_success
  assert_line "2: BUF=[#echo hi] CUR=8 PRE=[]"
  assert_line "3: BUF=[echo hi] CUR=7 PRE=[]"
}

# With accept-line-or-newline bound, Enter on an unfinished command opens a line
# in the same buffer instead of dropping to a PS2 prompt.
@test "Enter opens a new line in an unfinished command" {
  ZEPHYR_ZLE_RC="$TEST_HOME/rc.zsh"
  write_file "$ZEPHYR_ZLE_RC" \
    "zstyle ':zephyr:plugin:editor' accept-line-or-newline yes" \
    "source \$ZEPHYR_HOME/plugins/editor/editor.plugin.zsh"
  zephyr_zle <<'EOS'
type-keys 'for x in 1 2'
press enter
type-keys 'echo $x'
EOS
  assert_success
  assert_line "2: BUF=[for x in 1 2|] CUR=13 PRE=[]"
  assert_line "3: BUF=[for x in 1 2|echo \$x] CUR=20 PRE=[]"
}

@test "Enter still accepts a finished command" {
  ZEPHYR_ZLE_RC="$TEST_HOME/rc.zsh"
  write_file "$ZEPHYR_ZLE_RC" \
    "zstyle ':zephyr:plugin:editor' accept-line-or-newline yes" \
    "source \$ZEPHYR_HOME/plugins/editor/editor.plugin.zsh"
  zephyr_zle <<'EOS'
type-keys 'print done-marker'
press enter
EOS
  assert_success
  assert_line "2: BUF=[] CUR=0 PRE=[]"
}

#
# Home and End
#

@test "the line-or-buffer widgets are bound to Home and End" {
  zephyr_plugin editor <<'EOS'
print "home widget: ${widgets[beginning-of-line-or-buffer]:-none}"
print "end widget: ${widgets[end-of-line-or-buffer]:-none}"
for km in emacs viins vicmd; do
  print "$km: $(bindkey -M $km '^[[H' | awk '{print $2}') $(bindkey -M $km '^[[F' | awk '{print $2}')"
done
EOS
  assert_success
  assert_line "home widget: user:goto-line-or-buffer-edge"
  assert_line "end widget: user:goto-line-or-buffer-edge"
  assert_line "emacs: beginning-of-line-or-buffer end-of-line-or-buffer"
  assert_line "viins: beginning-of-line-or-buffer end-of-line-or-buffer"
  assert_line "vicmd: beginning-of-line-or-buffer end-of-line-or-buffer"
}

# The -hist widgets would walk history from the edge. These do not.
@test "Home and End stay put on a one-line buffer" {
  zephyr_zle <<'EOS'
type-keys 'echo one'
press $'\e[H'
press $'\e[H'
press $'\e[F'
press $'\e[F'
EOS
  assert_success
  assert_line "2: BUF=[echo one] CUR=0 PRE=[]"
  assert_line "3: BUF=[echo one] CUR=0 PRE=[]"
  assert_line "4: BUF=[echo one] CUR=8 PRE=[]"
  assert_line "5: BUF=[echo one] CUR=8 PRE=[]"
}

# Ctrl+V Ctrl+J puts a literal newline in the buffer, not a PS2 continuation.
@test "Home and End take the line first, then the whole buffer" {
  zephyr_zle <<'EOS'
type-keys 'aa'
press $'\x16\x0a'
press 'bbbb'
press $'\x16\x0a'
press 'cc'
press $'\e[H'
press $'\e[H'
press $'\e[F'
press $'\e[F'
EOS
  assert_success
  assert_line "5: BUF=[aa|bbbb|cc] CUR=10 PRE=[]"
  assert_line "6: BUF=[aa|bbbb|cc] CUR=8 PRE=[]"
  assert_line "7: BUF=[aa|bbbb|cc] CUR=0 PRE=[]"
  assert_line "8: BUF=[aa|bbbb|cc] CUR=2 PRE=[]"
  assert_line "9: BUF=[aa|bbbb|cc] CUR=10 PRE=[]"
}

#
# Ctrl+Z
#

# With nothing to resume, the line is left alone instead of running a doomed fg.
@test "Ctrl+Z on an empty line with no jobs does nothing" {
  zephyr_zle <<'EOS'
press $'\x1a'
type-keys 'echo after'
EOS
  assert_success
  assert_line "1: BUF=[] CUR=0 PRE=[]"
  assert_line "2: BUF=[echo after] CUR=10 PRE=[]"
}

# The jobs check comes first, so a typed line is not stashed out of sight for a
# resume that was never going to happen.
@test "Ctrl+Z with no jobs leaves a typed line alone" {
  zephyr_zle <<'EOS'
type-keys 'echo kept'
press $'\x1a'
EOS
  assert_success
  assert_line "1: BUF=[echo kept] CUR=9 PRE=[]"
  assert_line "2: BUF=[echo kept] CUR=9 PRE=[]"
}
