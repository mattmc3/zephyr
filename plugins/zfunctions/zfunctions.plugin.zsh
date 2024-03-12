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
_zfuncdir=${ZFUNCDIR:-${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions}
autoload-dir $_zfuncdir/functions(N/) $_zfuncdir/functions/*(N/)
unset _zfuncdir

# Mark this plugin as loaded.
zstyle ":zephyr:plugin:zfunctions" loaded 'yes'
