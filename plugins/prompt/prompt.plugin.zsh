#
# Requirements
#

if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

#
# External
#

-zephyr-clone miekg/lean
-zephyr-clone ohmyzsh/ohmyzsh
-zephyr-clone romkatv/powerlevel10k
-zephyr-clone sindresorhus/pure

fpath+="$ZEPHYRDIR/.external/lean"
fpath+="$ZEPHYRDIR/.external/powerlevel10k"
fpath+="$ZEPHYRDIR/.external/pure"

#
# Options
#

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#
# Init
#

fpath+="${0:A:h}/functions"
autoload -Uz promptinit && promptinit
zstyle -s ':zephyr:plugin:prompt' theme 'zephyr_theme' || zephyr_theme=pure
if [[ "$zephyr_theme" != "" ]]; then
  prompt "$zephyr_theme"
fi

#
# Customize
#

if [[ "$zephyr_theme" = "pure" ]]; then
  # show exit code on right
  precmd_pipestatus() {
    local exitcodes="${(j.|.)pipestatus}"
    if [[ "$exitcodes" != "0" ]]; then
      RPROMPT="%F{$prompt_pure_colors[prompt:error]}[$exitcodes]%f"
    else
      RPROMPT=
    fi
  }
  add-zsh-hook precmd precmd_pipestatus

  # https://unix.stackexchange.com/questions/685666/zsh-how-do-i-remove-block-prefixes-when-writing-multi-line-statements-in-intera
  # use 2 space indent for each new level
  PS2='${${${(%):-%_}//[^ ]}// /  }    '
fi

#
# Cleanup
#

unset zephyr_theme
