#
# External
#

# zstyle ':zephyr:plugin:syntax-highlighting' use-fast-syntax-highlighting 'yes'
if zstyle -t ':zephyr:plugin:syntax-highlighting' use-fast-syntax-highlighting; then
  -zephyr-clone-subplugin syntax-highlighting zdharma-continuum/fast-syntax-highlighting
  source ${0:A:h}/external/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
else
  -zephyr-clone-subplugin syntax-highlighting zsh-users/zsh-syntax-highlighting
  source ${0:A:h}/external/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fi
