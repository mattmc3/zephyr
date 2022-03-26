# autoload functions dir like fish

0=${(%):-%x}
fpath+="${0:A:h}/functions"
local _fn; for _fn in "${0:A:h}/functions"/*(.N); do
  autoload -Uz $_fn
done
unset _fn

if [[ -z "$ZFUNCDIR" ]]; then
  ZFUNCDIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config/zsh}}/functions
fi

[[ -d "$ZFUNCDIR" ]] || return
autoload-dir "$ZFUNCDIR"
for _fndir in $ZFUNCDIR/**/*(N/); do
  autoload-dir $_fndir
done
unset _fndir
