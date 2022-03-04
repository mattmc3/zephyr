# autoload functions dir like fish
autoad_funcdir ${0:a:h}/functions

if [[ -z "$ZFUNCDIR" ]]; then
  ZFUNCDIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions
fi

autoad_funcdir "$ZFUNCDIR"
for _fndir in $ZFUNCDIR/**/*(/); do
  autoad_funcdir $_fndir
done
unset _fndir
