#
# External
#

_zephyr_clone_plugin ohmyzsh/ohmyzsh
_zephyr_clone_prompt sindresorhus/pure

zstyle -a ':zephyr:prompt' plugins \
  '_zephyr_prompts' \
    || _zephyr_prompts=()
for _zephyr_prompt in $_zephyr_prompts; do
  _zephyr_clone_prompt $_zephyr_prompt
done
unset _zephyr_prompts{s,}

#
# Add prompts to fpath
#

fpath+="${0:A:h}/functions"
for _prompt_dir in "$ZEPHYRDIR"/.prompts/*(/); do
  fpath+="$_prompt_dir"
done
unset _prompt_dir

#
# Options
#

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#
# Init
#

autoload -Uz promptinit && promptinit
