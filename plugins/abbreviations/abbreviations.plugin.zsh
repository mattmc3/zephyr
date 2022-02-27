#
# External
#

-zephyr-clone-subplugin abbreviations olets/zsh-abbr
ABBR_USER_ABBREVIATIONS_FILE=${ABBR_USER_ABBREVIATIONS_FILE:-${ZDOTDIR:-~}/.zabbrs}
if (( ${+functions[zsh-defer]} )); then
  zsh-defer source ${0:A:h}/external/zsh-abbr/zsh-abbr.zsh
else
  source ${0:A:h}/external/zsh-abbr/zsh-abbr.zsh
fi
