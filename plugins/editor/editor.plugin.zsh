#
# editor - Set editor specific key bindings, options, and variables.
#

#
# Requirements
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%N}

#
# Zstyles
#

# Unless the user specifically turned it off, let's enable ../.. dot-expansion
if zstyle -T ':zephyr:plugin:editor' dot-expansion; then
  zstyle ':zephyr:plugin:editor' dot-expansion 'yes'
fi

#
# Init
#

# Use Prezto's editor module.
source ${0:a:h}/external/prezto_editor.zsh

#
# Options
#

# Undo Prezto options.
setopt NO_beep

#
# Keybindings
#

# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh
zmodload -i zsh/complist
bindkey -M menuselect '^o' accept-and-infer-next-history

#
# Wrap up
#

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:editor' loaded 'yes'
