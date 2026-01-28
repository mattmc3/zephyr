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

function update-cursor-style {
  # We currently only support the xterm family of terminals
  if ! is-term-family xterm && ! is-term-family rxvt && ! is-tmux; then
    return
  fi

  local style

  # Try to get style for the current keymap, fallback to sensible defaults
  zstyle -s ":zephyr:plugin:editor:$KEYMAP" cursor style
  if [[ -z "$style" ]]; then
    case "$KEYMAP" in
      main|emacs|viins) style=line ;;
      *)                style=block ;;
    esac
  fi

  # Print the cursor style, or do nothing and use the default.
  case $style in
    block)      printf '\e[2 q' ;;
    underscore) printf '\e[4 q' ;;
    line)       printf '\e[6 q' ;;
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

# Expand aliases
function glob-alias {
  local -a noexpand_aliases
  zstyle -a ':zephyr:plugin:editor:glob-alias' 'noexpand' 'noexpand_aliases' \
    || noexpand_aliases=()

  # Get last word to the left of the cursor:
  # (A) makes it an array even if there's only one element
  # (z) splits into words using shell parsing
  local word=${${(Az)LBUFFER}[-1]}
  if [[ $noexpand_aliases[(Ie)$word] -eq 0 ]]; then
    zle _expand_alias
    # zle expand-word
  fi
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
}

if zstyle -t ':zephyr:plugin:editor' 'magic-enter'; then
  # Wrapper for the accept-line zle widget (run when pressing Enter)
  # If the wrapper already exists don't redefine it
  if (( ! ${+functions[_magic-enter_accept-line]} )); then
    case "$widgets[accept-line]" in
      # Override the current accept-line widget, calling the old one
      user:*) zle -N _magic-enter_orig_accept-line "${widgets[accept-line]#user:}"
        function _magic-enter_accept-line {
          magic-enter
          zle _magic-enter_orig_accept-line -- "$@"
        } ;;
      # If no user widget defined, call the original accept-line widget
      builtin) function _magic-enter_accept-line {
          magic-enter
          zle .accept-line
        } ;;
    esac
    zle -N accept-line _magic-enter_accept-line
  fi
fi

#
# Init
#

# https://github.com/mattmc3/zephyr/issues/40
# Reset to default key bindings if we aren't using zsh-defer
if (( ! $+zsh_defer_options )); then
  bindkey -d
fi

#
# Keybinds
#

# Global keybinds
typeset -gA _zph_global_keybinds
_zph_global_keybinds=(
  "$key_info[Home]"   beginning-of-line
  "$key_info[End]"    end-of-line
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

# Toggle comment at the start of the line. Note that we use pound-toggle for emacs
# mode, which is similar to pound insert, but meant to work around some bugs.
bindkey -M emacs "$key_info[Escape];" pound-toggle
bindkey -M vicmd "#" vi-pound-insert

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

# Set the key layout.
zstyle -s ':zephyr:plugin:editor' key-bindings '_zph_key_bindings'
if [[ "$_zph_key_bindings" == (emacs|) ]]; then
  bindkey -e
elif [[ "$_zph_key_bindings" == vi ]]; then
  bindkey -v
else
  print "editor: invalid key bindings: $_zph_key_bindings" >&2
fi

#
# Clean up
#

unset _zph_{bind,key{,_bindings},keymap,feature}
unset _zph_{opt_in,opt_out}_keybinds _zph_{vicmd,viins,global}_keybinds

#region MARK LOADED
zstyle ':zephyr:plugin:editor' loaded 'yes'
#endregion
