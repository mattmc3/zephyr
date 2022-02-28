#
# External
#

# zstyle ':zephyr:plugin:syntax-highlighting' use-fast-syntax-highlighting 'yes'
if zstyle -t ':zephyr:plugin:syntax-highlighting' use-fast-syntax-highlighting; then
  -zephyr-load-plugin zdharma-continuum/fast-syntax-highlighting defer
else
  -zephyr-load-plugin zsh-users/zsh-syntax-highlighting
fi
