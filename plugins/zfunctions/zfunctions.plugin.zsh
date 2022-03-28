# autoload functions dir like fish

0=${(%):-%x}
(( $+functions[autoload-dir] )) || autoload ${0:A:h:h}/functions/autoload-dir
autoload-dir "${0:A:h}/functions"

if [[ -z "$ZFUNCDIR" ]]; then
  ZFUNCDIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions
fi

[[ -d "$ZFUNCDIR" ]] || return
autoload-dir "$ZFUNCDIR"
for _fndir in $ZFUNCDIR/**/*(N/); do
  autoload-dir $_fndir
done
unset _fndir
