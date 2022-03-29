#region: External

if [[ ! -d "${0:A:h}/external/fast-syntax-highlighting" ]]; then
  command git clone --quiet --depth 1 \
    https://github.com/zdharma-continuum/fast-syntax-highlighting \
    "${0:A:h}/external/fast-syntax-highlighting"
fi

if [[ ! -d "${0:A:h}/external/zsh-syntax-highlighting" ]]; then
  command git clone --quiet --depth 1 \
    https://github.com/zsh-users/zsh-syntax-highlighting \
    "${0:A:h}/external/zsh-syntax-highlighting"
fi

if zstyle -t ':zephyr:plugins:syntax-highlighting' use-fast-syntax-highlighting; then
  source "${0:A:h}/external/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
else
  source "${0:A:h}/external/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi

# endregion
