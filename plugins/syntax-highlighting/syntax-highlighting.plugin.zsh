#
# External
#

zstyle -s ':zephyr:plugin:syntax-highlighting' repo \
  '_syntax_plugin' || _syntax_plugin='zdharma-continuum/fast-syntax-highlighting'

if zstyle -T ':zephyr:plugin:syntax-highlighting' defer; then
  -zephyr-load-plugin $_syntax_plugin defer
else
  -zephyr-load-plugin $_syntax_plugin
fi

unset _syntax_plugin
