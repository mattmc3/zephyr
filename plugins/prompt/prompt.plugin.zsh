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
)
for _repo _prompt_name in ${(kv)_external_prompts}; do
  if [[ ! -d "${0:A:h}/external/$_prompt_name" ]]; then
    _prompt_dir="${0:A:h}/external/$_prompt_name"
    command git clone --quiet --depth 1 \
      https://github.com/$_repo \
      "$_prompt_dir"
    _prompt_init="${_prompt_dir}/prompt_${_prompt_name}_setup"
    if [[ ! -e "$_prompt_init" ]]; then
      _prompt_files=("$_prompt_dir"/prompt_*_setup(.N) "$_prompt_dir"/*.zsh-theme(.N))
      [[ ${#_prompt_files[@]} -gt 0 ]] && ln -sf "${_prompt_files[1]}" "$_prompt_init"
    fi
    unset _prompt_{dir,init,files}
  fi
  fpath+=("${0:A:h}/external/$_prompt_name")
done
unset _external_prompts _repo _prompt_name

#endregion

#region: Init

autoload -Uz promptinit && promptinit
zstyle -s ':zephyr:plugin:prompt' theme 'theme' || theme=pure
prompt $theme
unset theme

#endregion
