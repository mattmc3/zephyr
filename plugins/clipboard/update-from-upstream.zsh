#!/usr/bin/env zsh
#
# update-from-upstream.zsh
#
# This script updates the Zephyr clipboard utilities from Oh My Zsh. This is to be run
# by maintainers and not during normal use of the plugin.
#
# The official upstream repo is https://github.com/ohmyzsh/ohmyzsh
#
# This is a zsh script, not a function. Call it with `zsh update-from-upstream.zsh`
# from the command line, running it from within the plugin directory.
#

0=${(%):-%N}
ZEPHYR=${0:A:h:h:h}
PLUGIN=${0:A:h}
ZEPHYR_CACHE=${XDG_CACHE_HOME:=~/.cache}/zephyr
mkdir -p $ZEPHYR_CACHE

ZSH=$ZEPHYR_CACHE/plugins/ohmyzsh/ohmyzsh
if [[ -d $ZSH ]]; then
  git -C $ZSH pull --quiet --ff --rebase --autostash
else
  git clone --depth 1 --quiet https://github.com/ohmyzsh/ohmyzsh $ZSH
fi

mkdir -p $PLUGIN/external
cat $ZSH/lib/clipboard.zsh | awk -f $ZEPHYR/bin/filters/scrub_ohmyzsh >| $PLUGIN/external/omz_clipboard.zsh
for plugin in lib/clipboard.zsh plugins/copy{buffer,file,path}; do
  if [[ -d $ZSH/$plugin ]]; then
    plugin=$plugin/${plugin:t}.plugin.zsh
  fi
  awk -v FILE_PATH="$plugin" -f $ZEPHYR/bin/filters/scrub_ohmyzsh $ZSH/$plugin >| \
    $PLUGIN/external/omz_${plugin:t}
done
