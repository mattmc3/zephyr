#region HEADER
#
# editor: Setup Zsh line editor behavior.
#

# References:
# - https://github.com/belak/zsh-utils/blob/main/editor/editor.plugin.zsh
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/editor/init.zsh

0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
#endregion

# Return if requirements are not met.
[[ "$TERM" != 'dumb' ]] || return 1
! zstyle -t ":zephyr:plugin:editor" skip || return 0

#
# Options
#

# Set Zsh editor options.
setopt NO_beep                 # Do not beep on error in line editor.
setopt NO_flow_control         # Allow the usage of ^Q/^S in the context of zsh.

#
# Variables
#

# Treat these characters as part of a word.
zstyle -s ':zephyr:plugin:editor' wordchars 'WORDCHARS' || \
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Use human-friendly identifiers.
zmodload zsh/terminfo
typeset -gA key_info

# Modifiers
key_info=(
  'Control' '\C-'
  'Escape'  '\e'
  'Meta'    '\M-'
)

# Basic keys
key_info+=(
  'Backspace' "^?"
  'Delete'    "^[[3~"
  'F1'        "$terminfo[kf1]"
  'F2'        "$terminfo[kf2]"
  'F3'        "$terminfo[kf3]"
  'F4'        "$terminfo[kf4]"
  'F5'        "$terminfo[kf5]"
  'F6'        "$terminfo[kf6]"
  'F7'        "$terminfo[kf7]"
  'F8'        "$terminfo[kf8]"
  'F9'        "$terminfo[kf9]"
  'F10'       "$terminfo[kf10]"
  'F11'       "$terminfo[kf11]"
  'F12'       "$terminfo[kf12]"
  'Insert'    "$terminfo[kich1]"
  'Home'      "$terminfo[khome]"
  'PageUp'    "$terminfo[kpp]"
  'End'       "$terminfo[kend]"
  'PageDown'  "$terminfo[knp]"
  'Up'        "$terminfo[kcuu1]"
  'Left'      "$terminfo[kcub1]"
  'Down'      "$terminfo[kcud1]"
  'Right'     "$terminfo[kcuf1]"
  'BackTab'   "$terminfo[kcbt]"
)

# Mod plus another key
key_info+=(
  'AltLeft'         "${key_info[Escape]}${key_info[Left]} \e[1;3D"
  'AltRight'        "${key_info[Escape]}${key_info[Right]} \e[1;3C"
  'ControlLeft'     '\e[1;5D \e[5D \e\e[D \eOd'
  'ControlRight'    '\e[1;5C \e[5C \e\e[C \eOc'
  'ControlPageUp'   '\e[5;5~'
  'ControlPageDown' '\e[6;5~'
)

#
# Functions
#

# Runs bindkey but for all of the keymaps. Running it with no arguments will
# print out the mappings for all of the keymaps.
function bindkey-all {
  local keymap=''
  for keymap in $(bindkey -l); do
    [[ "$#" -eq 0 ]] && printf "#### %s\n" "${keymap}" 1>&2
    bindkey -M "${keymap}" "$@"
  done
}

# Binds one widget to several key sequences, skipping the ones a terminal
# doesn't report. Takes an optional leading -M <keymap>.
function bindkey-multiple {
  local -a keymap=()
  [[ "$1" == -M ]] && { keymap=(-M "$2"); shift 2 }
  local widget=$1 seq; shift
  for seq in "$@"; do
    [[ -n "$seq" ]] && bindkey $keymap "$seq" "$widget"
  done
}

function update-cursor-style {
  # We currently only support the xterm family of terminals
  if ! is-term-family xterm && ! is-term-family rxvt && ! is-tmux; then
    return
  fi

  # zle reports insert mode as `main`, which is viins under vi bindings and the
  # emacs keymap otherwise. Name it for the mode so the styles read plainly. The
  # layout was worked out once when the plugin loaded.
  local mode=${KEYMAP:-main}
  if [[ "$mode" == main ]]; then
    [[ "$_zph_editor_layout" == vi ]] && mode=viins || mode=emacs
  fi

  # Try to get style for the current keymap, fallback to sensible defaults
  local style
  if ! zstyle -s ":zephyr:plugin:editor:$mode" cursor style; then
    [[ "$mode" == vicmd ]] && style=block || style=line
  fi

  # Print the cursor style, or do nothing and use the default.
  case $style in
    block-blink)      printf '\e[1 q' ;;
    block)            printf '\e[2 q' ;;
    underscore-blink) printf '\e[3 q' ;;
    underscore)       printf '\e[4 q' ;;
    line-blink)       printf '\e[5 q' ;;
    line)             printf '\e[6 q' ;;
  esac
}
zle -N update-cursor-style

# Enables terminal application mode
function zle-line-init {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[smkx] )); then
    # Enable terminal application mode.
    echoti smkx
  fi

  # Ensure we have the correct cursor. We could probably do this less
  # frequently, but this does what we need and shouldn't incur that much
  # overhead.
  zle update-cursor-style
}
zle -N zle-line-init

# Disables terminal application mode
function zle-line-finish {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[rmkx] )); then
    # Disable terminal application mode.
    echoti rmkx
  fi
}
zle -N zle-line-finish

# Resets the prompt when the keymap changes
function zle-keymap-select {
  zle update-cursor-style

  zle reset-prompt
  zle -R
}
zle -N zle-keymap-select

# Expands .... to ../..
function dot-expansion {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N dot-expansion

# Inserts 'sudo ' at the beginning of the line.
function prepend-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}
zle -N prepend-sudo

# Expand the alias under the cursor. Kept apart from the widget below so it can also
# run as an accept-line hook, where inserting a character would be wrong.
function glob-alias-word {
  local -a noexpand_aliases expand_aliases
  zstyle -a ':zephyr:plugin:editor:glob-alias' 'noexpand' 'noexpand_aliases'
  zstyle -a ':zephyr:plugin:editor:glob-alias' 'expand' 'expand_aliases'

  # Get last word to the left of the cursor:
  # (A) makes it an array even if there's only one element
  # (z) splits into words using shell parsing
  local word=${${(Az)LBUFFER}[-1]}

  # Global aliases always expand. A plain one only expands when it isn't also a
  # command name, so ls='ls --color' is left alone. The two lists override that
  # both ways, noexpand first.
  if (( ! $noexpand_aliases[(Ie)$word] )); then
    (( $expand_aliases[(Ie)$word] || $+galiases[$word] || ! $+commands[$word] )) \
      && zle _expand_alias
  fi
}

# Expand aliases, then insert the key that got us here.
function glob-alias {
  glob-alias-word
  zle self-insert
}
zle -N glob-alias

# Toggle the comment character at the start of the line. This is meant to work
# around a buggy implementation of pound-insert in zsh.
#
# This is currently only used for the emacs keys because vi-pound-insert has
# been reported to work properly.
function pound-toggle {
  if [[ "$BUFFER" = '#'* ]]; then
    # Because of an oddity in how zsh handles the cursor when the buffer size
    # changes, we need to make this check before we modify the buffer and let
    # zsh handle moving the cursor back if it's past the end of the line.
    if [[ $CURSOR != $#BUFFER ]]; then
      (( CURSOR -= 1 ))
    fi
    BUFFER="${BUFFER:1}"
  else
    BUFFER="#$BUFFER"
    (( CURSOR += 1 ))
  fi
}
zle -N pound-toggle

# Copy the line being edited to the clipboard, PS2 continuation lines included.
function copybuffer {
  (( $+commands[pbcopy] || $+aliases[pbcopy] || $+functions[pbcopy] )) ||
    { zle -M "copybuffer: pbcopy not found"; return 1 }
  print -rn -- "$PREBUFFER$BUFFER" | pbcopy
}
zle -N copybuffer

# Home and End take the current line, then the whole buffer. $WIDGET says which end.
# Moves the cursor rather than calling the -hist widgets, which walk history.
function goto-line-or-buffer-edge {
  local -i edge
  if [[ "$WIDGET" == beginning-of* ]]; then
    [[ "$LBUFFER" == *$'\n'* ]] && edge=$(( ${#LBUFFER%$'\n'*} + 1 ))
    (( CURSOR = CURSOR == edge ? 0 : edge ))
  else
    edge=$#BUFFER
    [[ "$RBUFFER" == *$'\n'* ]] && edge=$(( CURSOR + ${#RBUFFER%%$'\n'*} ))
    (( CURSOR = CURSOR == edge ? $#BUFFER : edge ))
  fi
}
zle -N beginning-of-line-or-buffer goto-line-or-buffer-edge
zle -N end-of-line-or-buffer goto-line-or-buffer-edge

# Edit the current command in $EDITOR.
autoload -Uz edit-command-line
zle -N edit-command-line

# Complete the word under the cursor from history rather than the filesystem.
# The compstyles point this context at the _history completer.
zle -C hist-complete complete-word _generic

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh
# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
function symmetric-ctrl-z {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N symmetric-ctrl-z

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/magic-enter
(( $+functions[magic-enter-cmd] )) ||
function magic-enter-cmd {
  local cmd

  # jj goes first, so a colocated repo gets the jj command. No fork unless the
  # style is set, since jj is the rarer tool.
  if (( $+commands[jj] )) \
     && zstyle -s ':zephyr:plugin:editor:magic-enter' jj-command 'cmd' \
     && command jj st &>/dev/null; then
    echo $cmd
    return
  fi

  zstyle -s ':zephyr:plugin:editor:magic-enter' command 'cmd' ||
    cmd="ls ."

  if command git rev-parse --is-inside-work-tree &>/dev/null; then
    zstyle -s ':zephyr:plugin:editor:magic-enter' git-command 'cmd' ||
      cmd="git status -sb ."
  fi
  echo $cmd
}

function magic-enter {
  # Only run MAGIC_ENTER commands when in PS1 and command line is empty
  # http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#User_002dDefined-Widgets
  if [[ -n "$BUFFER" || "$CONTEXT" != start ]]; then
    return
  fi
  BUFFER=$(magic-enter-cmd)

  # A leading space keeps it out of history, given hist_ignore_space.
  [[ -n "$BUFFER" ]] && BUFFER=" $BUFFER"
  CURSOR=$#BUFFER
}

#
# Accept-line hooks
#

# $accept_line_hook and add-accept-line-hook come from lib/bootstrap.zsh, so a plugin
# can register a hook whether or not this one has loaded yet. What lives here is the
# widget that runs them.
#
# A hook that went away is skipped rather than spelled out to the terminal on
# every keypress. The loop variable is named oddly so hooks can use their own.
function run-accept-line-hooks {
  local _zph_hook
  for _zph_hook in $accept_line_hook; do
    (( $+functions[${_zph_hook%% *}] )) && "${=_zph_hook}"
  done
  return 0
}

# Wrap the widget rather than rebind Enter, so ^M, ^J, vicmd Enter, and widgets
# calling accept-line themselves all go through it. Whoever wrapped it first keeps
# their turn. The guard stops a re-source wrapping our own wrapper.
if (( ! $+functions[accept-line-with-hooks] )); then
  case "$widgets[accept-line]" in
    user:*)
      zle -N accept-line-orig "${widgets[accept-line]#user:}"
      function accept-line-with-hooks {
        run-accept-line-hooks
        zle accept-line-orig -- "$@"
      } ;;
    *)
      function accept-line-with-hooks {
        run-accept-line-hooks
        zle .accept-line
      } ;;
  esac
  zle -N accept-line accept-line-with-hooks
fi

if zstyle -t ':zephyr:plugin:editor' 'magic-enter'; then
  add-accept-line-hook magic-enter
fi

# Expand the alias under the cursor on Enter as well, not only on the expansion key:
#   zstyle ':zephyr:plugin:editor:glob-alias' on-accept 'yes'
# Off by default. It rewrites the line you are about to run, which is a bigger ask
# than expanding when you press a key for it.
if zstyle -t ':zephyr:plugin:editor:glob-alias' on-accept; then
  add-accept-line-hook glob-alias-word
fi

# True when $1 is a command ready to run. Compiling it as a function body is the
# test, so there is no subshell and nothing runs. Options stay the caller's here,
# or the answer would not be the one the prompt would give.
function command-is-complete {
  setopt local_options no_err_return no_err_exit
  local f=-zephyr-command-test

  # An odd number of trailing backslashes continues the line.
  (( ${#${1##*[^\\]}} % 2 )) && return 1

  unfunction -- $f 2>/dev/null
  functions[$f]="$1" 2>/dev/null || return 1
  [[ -v functions[$f] ]]         || return 1
  unfunction -- $f

  # `for x` and `cat <<END` are legal function bodies but unfinished commands.
  # If do/done finishes them, the command was waiting for more.
  functions[$f]="$1"$'\ndo\ndone' 2>/dev/null || return 0
  [[ -v functions[$f] ]]                      || return 0
  unfunction -- $f
  return 1
}

# Enter runs a finished command and opens a new line in an unfinished one, so a
# multi-line command is edited in one buffer rather than at a PS2 prompt. A
# command too broken to parse counts as unfinished, leaving room to fix it.
function accept-line-or-newline {
  if command-is-complete "$PREBUFFER$BUFFER"; then
    zle accept-line
  else
    # self-insert-unmeta rather than a newline of our own, so zsh-autosuggestions
    # sees the keypress. It is also why this belongs on Enter and nowhere else.
    zle self-insert-unmeta
  fi
}
zle -N accept-line-or-newline

#
# Init
#

# https://github.com/mattmc3/zephyr/issues/40
# Reset to default key bindings if we aren't using zsh-defer
if zstyle -t ':zephyr:plugin:editor' reset-keymaps && (( ! $+zsh_defer_options )); then
  bindkey -d
fi

# Free up Ctrl+S/Ctrl+Q from terminal flow control so zsh can bind them.
if [[ -o interactive && -r "${TTY:-}" && -w "${TTY:-}" ]] && (( $+commands[stty] )); then
  stty -ixon <"$TTY" >"$TTY"
fi

#
# Keybinds
#

# Global keybinds
typeset -gA _zph_global_keybinds
_zph_global_keybinds=(
  "$key_info[Home]"   beginning-of-line-or-buffer
  "$key_info[End]"    end-of-line-or-buffer
  "$key_info[Delete]" delete-char
)

# emacs and vi insert mode keybinds
typeset -gA _zph_viins_keybinds
_zph_viins_keybinds=(
  "$key_info[Backspace]" backward-delete-char
  "$key_info[Control]W"  backward-kill-word
)

# vi command mode keybinds
typeset -gA _zph_vicmd_keybinds
_zph_vicmd_keybinds=(
  "$key_info[Delete]" delete-char
)

# Special case for ControlLeft and ControlRight because they have multiple
# possible binds.
for _zph_key in "${(s: :)key_info[ControlLeft]}" "${(s: :)key_info[AltLeft]}"; do
  bindkey -M emacs "$_zph_key" emacs-backward-word
  bindkey -M viins "$_zph_key" vi-backward-word
  bindkey -M vicmd "$_zph_key" vi-backward-word
done
for _zph_key in "${(s: :)key_info[ControlRight]}" "${(s: :)key_info[AltRight]}"; do
  bindkey -M emacs "$_zph_key" emacs-forward-word
  bindkey -M viins "$_zph_key" vi-forward-word
  bindkey -M vicmd "$_zph_key" vi-forward-word
done

# Bind all global and viins keys to the emacs keymap
for _zph_key _zph_bind in ${(kv)_zph_global_keybinds} ${(kv)_zph_viins_keybinds}; do
  bindkey -M emacs "$_zph_key" "$_zph_bind"
done

# Bind all global, vi, and viins keys to the viins keymap
for _zph_key _zph_bind in ${(kv)_zph_global_keybinds} ${(kv)_zph_viins_keybinds}; do
  bindkey -M viins "$_zph_key" "$_zph_bind"
done

# Bind all global, vi, and vicmd keys to the vicmd keymap
for _zph_key _zph_bind in ${(kv)_zph_global_keybinds} ${(kv)_zph_vicmd_keybinds}; do
  bindkey -M vicmd "$_zph_key" "$_zph_bind"
done

# terminfo names only the Home and End this terminal sends, so bind the xterm forms too.
for _zph_keymap in emacs viins vicmd; do
  bindkey-multiple -M "$_zph_keymap" beginning-of-line-or-buffer '^[[H'
  bindkey-multiple -M "$_zph_keymap" end-of-line-or-buffer       '^[[F'
done

# Toggle comment at the start of the line. Note that we use pound-toggle for emacs
# mode, which is similar to pound insert, but meant to work around some bugs.
bindkey -M emacs "$key_info[Escape];" pound-toggle
bindkey -M vicmd "#" vi-pound-insert

# Edit the command in $EDITOR, complete from history, and copy the line to the
# clipboard. Ctrl+X Ctrl+C is unbound by default, unlike the Ctrl+O other configs
# use, which is accept-line-and-down-history.
for _zph_keymap in emacs viins vicmd; do
  bindkey -M "$_zph_keymap" '^X^E' edit-command-line
  bindkey -M "$_zph_keymap" '^X^X' hist-complete
  bindkey -M "$_zph_keymap" '^X^C' copybuffer
done

# Enter opens a new line in an unfinished command instead of dropping to a PS2
# prompt. Hijacking Enter is not polite, so this one is opt-in.
if zstyle -t ':zephyr:plugin:editor' accept-line-or-newline; then
  for _zph_keymap in emacs viins; do
    bindkey -M "$_zph_keymap" '^M' accept-line-or-newline
    bindkey -M "$_zph_keymap" '^J' accept-line-or-newline
  done
fi

# Optional keybindings for emacs and viins keymaps
typeset -A _zph_opt_in_keybinds _zph_opt_out_keybinds
_zph_opt_in_keybinds=(
  dot-expansion "."
)
_zph_opt_out_keybinds=(
  symmetric-ctrl-z '^Z'
  prepend-sudo     '^X^S'
)

# Opt-in features (disabled by default)
for _zph_feature _zph_key in ${(kv)_zph_opt_in_keybinds}; do
  if zstyle -t ':zephyr:plugin:editor' "$_zph_feature"; then
    for _zph_keymap in 'emacs' 'viins'; do
      bindkey -M "$_zph_keymap" "$_zph_key" "$_zph_feature"
    done
  fi
done

# Opt-out features (enabled by default)
for _zph_feature _zph_key in ${(kv)_zph_opt_out_keybinds}; do
  if zstyle -T ':zephyr:plugin:editor' "$_zph_feature"; then
    for _zph_keymap in 'emacs' 'viins'; do
      bindkey -M "$_zph_keymap" "$_zph_key" "$_zph_feature"
    done
  fi
done

# Do not expand .... to ../.. during incremental search.
if zstyle -t ':zephyr:plugin:editor' dot-expansion; then
  bindkey -M isearch . self-insert 2> /dev/null
fi

# Expand aliases with space automatically (opt-in, overrides glob-alias)
if zstyle -t ':zephyr:plugin:editor' automatic-glob-alias; then
  for _zph_keymap in 'emacs' 'viins'; do
    bindkey -M "$_zph_keymap" " " glob-alias
    bindkey -M "$_zph_keymap" "^ " magic-space
  done
  bindkey -M isearch " " magic-space
# Expand aliases with ctrl-space (opt-out, enabled by default)
elif zstyle -T ':zephyr:plugin:editor' glob-alias; then
  for _zph_keymap in 'emacs' 'viins'; do
    bindkey -M "$_zph_keymap" "^ " glob-alias
    bindkey -M "$_zph_keymap" " " magic-space
  done
  bindkey -M isearch " " magic-space
fi

#
# Layout
#

# Set the key layout: emacs, vi, or existing.
#   zstyle ':zephyr:plugin:editor' key-bindings 'existing'
# `existing` leaves whatever keymap is already linked to main, for people who ran
# `bindkey -v` themselves or load something like zsh-vi-mode. Choosing emacs or vi
# overrides that, and orphans anything bound with a bare `bindkey` beforehand: the
# binding stays in the old keymap, which is no longer the one main points at.
#
# $_zph_editor_layout records which of the two we ended up in, so
# update-cursor-style can name its styles for the mode without asking again. Under
# `existing` that costs one subshell, paid only by those who ask for it.
typeset -g _zph_editor_layout
zstyle -s ':zephyr:plugin:editor' key-bindings '_zph_key_bindings'
case "$_zph_key_bindings" in
  emacs|'')
    bindkey -e
    _zph_editor_layout=emacs ;;
  vi)
    bindkey -v
    _zph_editor_layout=vi ;;
  existing)
    [[ "$(bindkey -lL main)" == *viins* ]] && _zph_editor_layout=vi \
                                           || _zph_editor_layout=emacs ;;
  *)
    print "editor: invalid key bindings: $_zph_key_bindings" >&2
    _zph_editor_layout=emacs ;;
esac

#
# Clean up
#

unset _zph_{bind,key{,_bindings},keymap,feature}
unset _zph_{opt_in,opt_out}_keybinds _zph_{vicmd,viins,global}_keybinds

#region MARK LOADED
zstyle ':zephyr:plugin:editor' loaded 'yes'
#endregion
