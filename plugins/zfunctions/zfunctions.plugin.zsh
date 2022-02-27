# autoload functions dir like fish
if [[ -z "$ZFUNCDIR" ]]; then
  ZFUNCDIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions
fi
fpath+="$ZFUNCDIR"
for f in $ZFUNCDIR/**/*(.N); do
  autoload -Uz $f
done
unset f
