0=${(%):-%x}
for _zephyr_plugin in "${0:A:h}"/plugins/*/*.plugin.zsh; do
  source $_zephyr_plugin
done
unset _zephyr_plugin
