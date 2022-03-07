# autoload functions dir like fish
_zephyr_autoload_funcdir ${0:a:h}/functions

if [[ -z "$ZFUNCDIR" ]]; then
  ZFUNCDIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions
fi

_zephyr_autoload_funcdir "$ZFUNCDIR"
for _fndir in $ZFUNCDIR/**/*(/); do
  _zephyr_autoload_funcdir $_fndir
done
unset _fndir
