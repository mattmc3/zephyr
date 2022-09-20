#
# Requirements
#

0=${(%):-%x}
if ! (( $+functions[zephyrinit] )); then
  autoload -Uz ${0:A:h:h:h}/functions/zephyrinit && zephyrinit
fi

(( $+functions[autoload-dir] )) || autoload -Uz $ZEPHYR_HOME/functions/autoload-dir
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
