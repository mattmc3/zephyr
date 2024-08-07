#
# completion: Set up zsh completions.
#

# References:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh#L31-L44
# - https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin#L9-L15
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit
# - https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2894219
# - https://htr3n.github.io/2018/07/faster-zsh/

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

#region BOOTSTRAP
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap'    loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
zstyle -t ':zephyr:plugin:compstyle' loaded || source $ZEPHYR_HOME/plugins/compstyle/compstyle.plugin.zsh
#endregion BOOTSTRAP

# 16.2.2 Completion
setopt always_to_end        # Move cursor to the end of a completed word.
setopt auto_list            # Automatically list choices on ambiguous completion.
setopt auto_menu            # Show completion menu on a successive tab press.
setopt auto_param_slash     # If completed parameter is a directory, add a trailing slash.
setopt complete_in_word     # Complete from both ends of a word.
setopt NO_menu_complete     # Do not autoselect the first completion entry.

# 16.2.3 Expansion and Globbing
setopt extended_glob        # Needed for file modification glob modifiers with compinit.

# 16.2.6 Input/Output
setopt path_dirs            # Perform path search even on command names with slashes.
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
fpath=($__zsh_config_dir/completions(-/FN) $fpath)

function run_compinit {
  emulate -L zsh
  setopt localoptions extendedglob

  # Use ZSH_COMPDUMP for location of completion file.
  local zcompdump
  if [[ -n "$ZSH_COMPDUMP" ]]; then
    zcompdump="$ZSH_COMPDUMP"
  else
    zcompdump="${__zsh_cache_dir:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/zcompdump"
  fi
  [[ -d $zcompdump:h ]] || mkdir -p $zcompdump:h

  # `run_compinit -f` forces a cache reset.
  if [[ "$1" == "-f" ]] || [[ "$1" == "--force" ]]; then
    shift
    [[ -f "$zcompdump" ]] && rm -rf -- $zcompdump
  fi

  # Compfix flag
  local -a compinit_flags=(-d "$zcompdump")
  if zstyle -t ':zephyr:plugin:completion' 'disable-compfix'; then
    # Allow insecure directories in fpath
    compinit_flags=(-u $compinit_flags)
  else
    # Remove insecure directories from fpath
    compinit_flags=(-i $compinit_flags)
  fi

  # Initialize completions
  autoload -Uz compinit
  if zstyle -t ':zephyr:plugin:completion' 'use-cache'; then
    # Load and initialize the completion system ignoring insecure directories with a
    # cache time of 20 hours, so it should almost always regenerate the first time a
    # shell is opened each day.
    local compdump_cache=($zcompdump(Nmh-20))
    if (( $#compdump_cache )); then
      compinit -C $compinit_flags
    else
      compinit $compinit_flags
      # Ensure $zcompdump is younger than the cache time even if it isn't regenerated.
      touch "$zcompdump"
    fi
  else
    compinit $compinit_flags
  fi

  # Compile zcompdump, if modified, in background to increase startup speed.
  {
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
      if command mkdir "${zcompdump}.zwc.lock" 2>/dev/null; then
        zcompile "$zcompdump"
        command rmdir  "${zcompdump}.zwc.lock" 2>/dev/null
      fi
    fi
  } &!
}

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
  run_compinit
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

    # Apply all the queued compdefs.
    local typedef_compdef_args
    for typedef_compdef_args in $__zephyr_compdef_queue; do
      eval $typedef_compdef_args
      compdef "$compdef_args[@]"
    done
    unset __zephyr_compdef_queue

    # If we're here, it's because the user manually ran compinit, which means we
    # no longer need the failsafe hook.
    hooks-add-hook -d post_zshrc run-compinit-post-zshrc
  }

  # Failsafe to make sure compinit runs during the post_zshrc event
  function run-compinit-post-zshrc {
    run_compinit
    hooks-add-hook -d post_zshrc run-compinit-post-zshrc
  }
  hooks-add-hook post_zshrc run-compinit-post-zshrc
fi

# Set the completion style
zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
if (( $+functions[compstyle_${zcompstyle}_setup] )); then
  compstyle_${zcompstyle}_setup
elif [[ "$zcompstyle" != none ]]; then
  compstyleinit && compstyle ${zcompstyle}
fi
unset zcompstyle

#region MARK LOADED
zstyle ':zephyr:plugin:completion' loaded 'yes'
#endregion
