####
# clipboard - Handy cross-platform clipboard functions.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

# Autoload functions.
fpath=(${0:A:h}/functions $fpath)
autoload -U $fpath[1]/*(.:t)

# Detect clipboard at load, just like OMZ does.
detect-clipboard

#
# Keybindings
#

zle -N copybuffer
bindkey -M emacs "^O" copybuffer
bindkey -M viins "^O" copybuffer
bindkey -M vicmd "^O" copybuffer

#
# Cleanup
#

zstyle ":zephyr:plugin:clipboard" loaded 'yes'
