#
# Set keybindings.
#

#region: Requirements
[[ "$TERM" != 'dumb' ]] || return 1
#endregion

#region: Options
setopt NO_BEEP                  # no beep on error in line editor
unsetopt FLOW_CONTROL           # allow the usage of ^Q/^S in the context of zsh
#endregion

#region: Variables
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"
export PAGER="${PAGER:-less}"
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="${BROWSER:-open}"
fi

# Less
# mouse-wheel scrolling can be disabled with -X (disable screen clearing)
[[ -z "$LESS" ]] && export LESS='-g -i -M -R -S -w -z-4'

# set the Less input preprocessor
# try both `lesspipe` and `lesspipe.sh` as either might exist on a system
if (( $#commands[(i)lesspipe(|.sh)] )) && [[ -z "$LESSOPEN" ]]; then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER

# treat these characters as part of a word
[[ -z "$WORDCHARS" ]] || WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Use human-friendly identifiers
zmodload zsh/terminfo
typeset -gA key_info

# Modifiers
key_info=(
  'Control'      '\C-'
  'Escape'       '\e'
  'Meta'         '\M-'
)

# Basic keys
key_info+=(
  'Backspace'    "^?"
  'Delete'       "^[[3~"
  'F1'           "$terminfo[kf1]"
  'F2'           "$terminfo[kf2]"
  'F3'           "$terminfo[kf3]"
  'F4'           "$terminfo[kf4]"
  'F5'           "$terminfo[kf5]"
  'F6'           "$terminfo[kf6]"
  'F7'           "$terminfo[kf7]"
  'F8'           "$terminfo[kf8]"
  'F9'           "$terminfo[kf9]"
  'F10'          "$terminfo[kf10]"
  'F11'          "$terminfo[kf11]"
  'F12'          "$terminfo[kf12]"
  'Insert'       "$terminfo[kich1]"
  'Home'         "$terminfo[khome]"
  'PageUp'       "$terminfo[kpp]"
  'End'          "$terminfo[kend]"
  'PageDown'     "$terminfo[knp]"
  'Up'           "$terminfo[kcuu1]"
  'Left'         "$terminfo[kcub1]"
  'Down'         "$terminfo[kcud1]"
  'Right'        "$terminfo[kcuf1]"
  'BackTab'      "$terminfo[kcbt]"
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
#endregion

#region: Functions
# Runs bindkey but for all of the keymaps. Running it with no arguments will
# print out the mappings for all of the keymaps.
function bindkey-all {
  local keymap=''
  for keymap in $(bindkey -l); do
    [[ "$#" -eq 0 ]] && printf "#### %s\n" "${keymap}" 1>&2
    bindkey -M "${keymap}" "$@"
  done
}

function is-term-family {
  if [[ $TERM = $1 || $TERM = $1-* ]]; then
    return 0
  fi
  return 1
}

function is-tmux {
  if is-term-family tmux; then
    return 0
  fi
  if [[ -n "$TMUX" ]]; then
    return 0
  fi
  return 1
}

function update-cursor-style {
  # We currently only support the xterm family of terminals
  if ! is-term-family xterm && ! is-term-family rxvt && ! is-tmux; then
    return
  fi

  if bindkey -lL main | grep viins > /dev/null; then
    # For vi-mode we
    case $KEYMAP in
      vicmd)      printf '\e[2 q';;
      viins|main) printf '\e[6 q';;
    esac
  else
    # if we're in emacs mode, we always want the block cursor
    printf '\e[2 q'
  fi
}
zle -N update-cursor-style

# enables terminal application mode
function zle-line-init {
  # the terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid
  if (( $+terminfo[smkx] )); then
    # Enable terminal application mode
    echoti smkx
  fi

  # Ensure we have the correct cursor. We could probably do this less
  # frequently, but this does what we need and shouldn't incur that much
  # overhead
  zle update-cursor-style
}
zle -N zle-line-init

# Disables terminal application mode
function zle-line-finish {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid
  if (( $+terminfo[rmkx] )); then
    # Disable terminal application mode
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
#endregion

#region: Keybinds
# Reset to default key bindings
bindkey -d

# Global keybinds
local -A global_keybinds
global_keybinds=(
  "$key_info[Home]"   beginning-of-line
  "$key_info[End]"    end-of-line
  "$key_info[Delete]" delete-char
)

# emacs and vi insert mode keybinds
local -A viins_keybinds
viins_keybinds=(
  "$key_info[Backspace]" backward-delete-char
  "$key_info[Control]W"  backward-kill-word
)

# vi command mode keybinds
local -A vicmd_keybinds
vicmd_keybinds=(
  "$key_info[Delete]" delete-char
)

# Special case for ControlLeft and ControlRight because they have multiple
# possible binds
for key in "${(s: :)key_info[ControlLeft]}" "${(s: :)key_info[AltLeft]}"; do
  bindkey -M emacs "$key" emacs-backward-word
  bindkey -M viins "$key" vi-backward-word
  bindkey -M vicmd "$key" vi-backward-word
done
for key in "${(s: :)key_info[ControlRight]}" "${(s: :)key_info[AltRight]}"; do
  bindkey -M emacs "$key" emacs-forward-word
  bindkey -M viins "$key" vi-forward-word
  bindkey -M vicmd "$key" vi-forward-word
done

# Bind all global and viins keys to the emacs keymap
for key bind in ${(kv)global_keybinds} ${(kv)viins_keybinds}; do
  bindkey -M emacs "$key" "$bind"
done

# Bind all global, vi, and viins keys to the viins keymap
for key bind in ${(kv)global_keybinds} ${(kv)viins_keybinds}; do
  bindkey -M viins "$key" "$bind"
done

# Bind all global, vi, and vicmd keys to the vicmd keymap
for key bind in ${(kv)global_keybinds} ${(kv)vicmd_keybinds}; do
  bindkey -M vicmd "$key" "$bind"
done
#endregion
