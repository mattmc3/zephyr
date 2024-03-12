#
# zfunctions - Autoload all function files from your $ZDOTDIR/functions directory.
#

# Set required Zsh options.
setopt extended_glob

##? autoload-dir - Autoload function files in directory
function autoload-dir {
  emulate -L zsh; setopt local_options extended_glob
  local zdir
  local -a zautoloads
  for zdir in $@; do
    [[ -d "$zdir" ]] || continue
    fpath=("$zdir" $fpath)
    zautoloads=($zdir/*~_*(N.:t))
    (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
  done
}

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
