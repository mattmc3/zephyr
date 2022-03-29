#
# Add Zephyr prompts to fpath
#

0=${(%):-%x}
fpath+="${0:A:h}/functions"

#region: Options

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#endregion

#region: External

typeset -A _external_prompts=(
  sindresorhus/pure      pure
  romkatv/powerlevel10k  powerlevel10k
  dracula/zsh            dracula
  ohmyzsh/ohmyzsh        ohmyzsh
)
for _repo _prompt_name in ${(kv)_external_prompts}; do
  if [[ ! -d "${0:A:h}/external/$_prompt_name" ]]; then
    command git clone --quiet --depth 1 \
      https://github.com/$_repo \
      "${0:A:h}/external/$_prompt_name"
  fi
  fpath+=("${0:A:h}/external/$_prompt_name")
done

#endregion

#region: Set prompt

autoload -Uz promptinit && promptinit
zstyle -s ':zephyr:plugin:prompt' theme _theme || _theme=pure
prompt $_theme

#endregion

#region: Customizations

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

unset _theme _external_prompts _repo _prompt_name

#endregion
