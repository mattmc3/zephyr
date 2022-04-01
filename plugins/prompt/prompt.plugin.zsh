#
# Add Zephyr prompts to fpath
#

#region: Init
0=${(%):-%x}
zstyle -t ':zephyr:core' initialized || source ${0:A:h:h:h}/lib/init.zsh
#endregion

#region: Functions
autoload-dir "${0:A:h}/functions"
#endregion

#region: Options
# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables
#endregion

#region: External
fpath=(
  "$ZEPHYR_HOME"/.external/sindresorhus/pure
  "$ZEPHYR_HOME"/.external/romkatv/powerlevel10k
  $fpath
)
# endregion

#region: Set prompt
autoload -Uz promptinit && promptinit
zstyle -s ':zephyr:plugin:prompt' theme _theme || _theme=pure
prompt $_theme
#endregion

#region: Customize
if [[ "$_theme" = "pure" ]]; then
  if zstyle -t ':zephyr:plugin:prompt:pure' show-exit-code; then
    # show exit code on right
    function precmd_pipestatus {
      local exitcodes="${(j.|.)pipestatus}"
      if [[ "$exitcodes" != "0" ]]; then
        RPROMPT="%F{$prompt_pure_colors[prompt:error]}[$exitcodes]%f"
      else
        RPROMPT=
      fi
    }
    add-zsh-hook precmd precmd_pipestatus
  fi
fi
#endregion

#region: Cleanup
unset _theme
#endregion
