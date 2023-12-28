#
# completion - Set up zsh completions.
#

# References:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh#L31-L44
# - https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin#L9-L15
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit
# - https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2894219
# - https://htr3n.github.io/2018/07/faster-zsh/

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:boostrap' loaded || source ${0:a:h:h:h}/lib/boostrap.zsh
-zephyr-autoload-dir ${0:a:h}/functions

# Set Zsh completion options.
setopt complete_in_word     # Complete from both ends of a word.
setopt always_to_end        # Move cursor to the end of a completed word.
setopt auto_menu            # Show completion menu on a successive tab press.
setopt auto_list            # Automatically list choices on ambiguous completion.
setopt auto_param_slash     # If completed parameter is a directory, add a trailing slash.
setopt extended_glob        # Needed for file modification glob modifiers with compinit.
setopt NO_menu_complete     # Do not autoselect the first completion entry.
setopt NO_flow_control      # Disable start/stop characters in shell editor.

# Add completions for keg-only brews when available.
if (( $+commands[brew] )); then
  brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-$commands[brew]:A:h:h}}
  # $HOMEBREW_PREFIX defaults to $HOMEBREW_REPOSITORY but is explicitly set to
  # /usr/local when $HOMEBREW_REPOSITORY is /usr/local/Homebrew.
  # https://github.com/Homebrew/brew/blob/2a850e02d8f2dedcad7164c2f4b95d340a7200bb/bin/brew#L66-L69
  [[ $brew_prefix == '/usr/local/Homebrew' ]] && brew_prefix=$brew_prefix:h

  # Add brew locations to fpath
  fpath=(
    # Add curl completions from homebrew.
    $brew_prefix/opt/curl/share/zsh/site-functions(/N)

    # Add zsh completions.
    $brew_prefix/share/zsh/site-functions(-/FN)

    $fpath
  )
  unset brew_prefix
fi

# Add custom completions.
fpath=(${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/completions(-/FN) $fpath)

# Initialize completions.
if ! zstyle -t ':zephyr:plugin:completion' manual; then
  run-compinit
fi

# Set the completion style
zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
if (( $+functions[compstyle_${zcompstyle}_setup] )); then
  compstyle_${zcompstyle}_setup
fi
unset zcompstyle

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:completion' loaded 'yes'
