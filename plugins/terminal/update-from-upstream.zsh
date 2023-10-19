#!/usr/bin/env zsh
#
# update-from-upstream.zsh
#
# This script updates the Zephyr clipboard utilities from Prezto. This is to be run
# by maintainers and not during normal use of the plugin.
#
# The official upstream repo is https://github.com/sorin-ionescu/prezto
#
# This is a zsh script, not a function. Call it with `zsh update-from-upstream.zsh`
# from the command line, running it from within the plugin directory.
#

0=${(%):-%N}
ZEPHYR=${0:A:h:h:h}
PLUGIN=${0:A:h}
ZEPHYR_CACHE=${XDG_CACHE_HOME:=~/.cache}/zephyr
repo=sorin-ionescu/prezto
mkdir -p $ZEPHYR_CACHE

ZPREZTODIR=$ZEPHYR_CACHE/plugins/$repo
if [[ -d $ZPREZTODIR ]]; then
  git -C $ZPREZTODIR pull --quiet --ff --rebase --autostash
else
  git clone --depth 1 --quiet https://github.com/$repo $ZPREZTODIR
fi

mkdir -p $PLUGIN/external
cat $ZPREZTODIR/modules/terminal/init.zsh | \
  awk -v FILE_PATH="modules/terminal/init.zsh" -f $ZEPHYR/bin/filters/scrub_prezto >| \
  $PLUGIN/external/prezto_terminal.zsh
