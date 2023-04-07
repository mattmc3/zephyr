##? zfunctions - Use a Fish-like functions directory for zsh functions.

# Load plugins functions.
fpath=("${0:A:h}/functions" $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Load zfunctions.
if [[ -z "$ZFUNCDIR" ]]; then
  ZFUNCDIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions
fi
[[ -d "$ZFUNCDIR" ]] || return
fpath=("$ZFUNCDIR" $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Load zfunctions subdirs.
for _fndir in $ZFUNCDIR(N/) $ZFUNCDIR/*(N/); do
  fpath=("$_fndir" $fpath)
  autoload -Uz $fpath[1]/*(.:t)
done
unset _fndir

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:zfunctions" loaded 'yes'
