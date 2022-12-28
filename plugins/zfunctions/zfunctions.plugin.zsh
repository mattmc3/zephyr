###
# zfunctions - Use a Fish-like functions directory for zsh functions.
###

#
# Requirements
#

zstyle -t ':zephyr:core' initialized || return 1

#
# Init
#

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
