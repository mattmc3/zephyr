#
# Integrates Zsh syntax highlighting into Zephyr.
#

#region: Requirements
[[ "$TERM" != 'dumb' ]] || return 1
#endregion

#region: Init
0=${(%):-%x}
zstyle -t ':zephyr:core' initialized || source ${0:A:h:h:h}/lib/init.zsh
#endregion

#region: External
if zstyle -t ':zephyr:plugins:syntax-highlighting' use-fast-syntax-highlighting; then
  source "$ZEPHYR_HOME/.external/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
else
  source "$ZEPHYR_HOME/.external/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
# endregion
