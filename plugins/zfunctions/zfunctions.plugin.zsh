#
# zfunctions: Autoload all function files from your $ZDOTDIR/functions directory.
#

# Set required Zsh options.
setopt extended_glob

# Load required functions.
0=${(%):-%N}
if (( ! $+functions[autoload-dir] )); then
  ZEPHYR_HOME=${0:a:h:h:h}
  fpath=($ZEPHYR_HOME/functions $fpath)
  autoload -Uz autoload-dir
fi
autoload-dir ${0:a:h}/functions

# Load zfunctions.
zstyle -a ':zephyr:plugin:zfunctions' directory '_zfuncdir' ||
  _zfuncdir=(
    ${ZFUNCDIR:-${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions}(/N)
  )
(( $#_zfuncdir )) || return 1
autoload-dir ${~_zfuncdir[1]}(N/) ${~_zfuncdir[1]}/*(N/)
unset _zfuncdir

# Mark this plugin as loaded.
zstyle ":zephyr:plugin:zfunctions" loaded 'yes'
