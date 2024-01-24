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
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
autoload-dir ${0:a:h}/functions

# Set Zsh completion options.
setopt complete_in_word     # Complete from both ends of a word.
setopt always_to_end        # Move cursor to the end of a completed word.
setopt auto_menu            # Show completion menu on a successive tab press.
setopt auto_list            # Automatically list choices on ambiguous completion.
setopt auto_param_slash     # If completed parameter is a directory, add a trailing slash.
setopt extended_glob        # Needed for file modification glob modifiers with compinit.
setopt NO_menu_complete     # Do not autoselect the first completion entry.
setopt NO_flow_control      # Disable start/stop characters in shell editor.

# Add other upstream completions to $fpath.
fpath=(
  ${0:a:h}/external/src  # zsh-users/zsh-completions
  ${0:a:h}/completions   # starship, git contrib
  $fpath
)

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

# Let's talk compinit... compinit works by finding _completion files in your fpath. That
# means fpath has to be fully populated prior to calling compinit. If you use oh-my-zsh,
# if populates fpath and runs compinit prior to loading plugins. This is only
# problematic if you expect to be able to add to fpath later. Conversely, if you wait to
# run compinit until the end of your config, then functions like compdef aren't
# available earlier in your config.
#
# TLDR; this code handles all those use cases and simply queues calls to compdef and
# hooks compinit to precmd for one call only, which happens automatically at the end of
# your config. You can override this behavior with zstyles.
if zstyle -t ':zephyr:plugin:completion' immediate; then
  run-compinit
else
  # Define compinit placeholder functions (compdef) so we can queue up calls to compdef.
  # That way when the real compinit is called, we can execute the queue.
  typeset -gHa __zephyr_compdef_queue=()
  function compdef {
    (( $# )) || return
    local compdef_args=("${@[@]}")
    __zephyr_compdef_queue+=("$(typeset -p compdef_args)")
  }

  # Wrap compinit temporarily so that when the real compinit call happens, the
  # queue of compdef calls is processed.
  function compinit {
    unfunction compinit compdef &>/dev/null
    autoload -Uz compinit && compinit "$@"
    local typedef_compdef_args
    for typedef_compdef_args in $__zephyr_compdef_queue; do
      eval $typedef_compdef_args
      compdef "$compdef_args[@]"
    done
    unset __zephyr_compdef_queue
  }

  # If the user didn't specify they wanted to manually initialize completions,
  # then attach compinit to the precmd hook so that it happens at the very end.
  if ! zstyle -t ':zephyr:plugin:completion' manual; then
    autoload -Uz add-zsh-hook
    function run-compinit-precmd {
      run-compinit
      add-zsh-hook -d precmd run-compinit-precmd
    }
    add-zsh-hook precmd run-compinit-precmd
  fi
fi

# Set the completion style
zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
if (( $+functions[compstyle_${zcompstyle}_setup] )); then
  compstyle_${zcompstyle}_setup
else
  compstyleinit && compstyle ${zcompstyle}
fi
unset zcompstyle

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:completion' loaded 'yes'
