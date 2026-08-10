#region HEADER
#
# completion: Set up zsh completions.
#

# References:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh#L31-L44
# - https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin#L9-L15
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit
# - https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2894219
# - https://htr3n.github.io/2018/07/faster-zsh/

0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap'    loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
zstyle -t ':zephyr:plugin:compstyle' loaded || source $ZEPHYR_HOME/plugins/compstyle/compstyle.plugin.zsh
#endregion

# Return if requirements are not met.
[[ "$TERM" != 'dumb' ]] || return 1
! zstyle -t ":zephyr:plugin:completion" skip || return 0

# Set completion options.
setopt always_to_end        # Move cursor to the end of a completed word.
setopt auto_list            # Automatically list choices on ambiguous completion.
setopt auto_menu            # Show completion menu on a successive tab press.
setopt auto_param_slash     # If completed parameter is a directory, add a trailing slash.
setopt complete_in_word     # Complete from both ends of a word.
setopt path_dirs            # Perform path search even on command names with slashes.
setopt NO_flow_control      # Disable start/stop characters in shell editor.
setopt NO_list_beep         # Do not beep on ambiguous completion.
setopt NO_menu_complete     # Do not autoselect the first completion entry.

# Needed by the menu-select styles the compstyles set.
zmodload zsh/complist

# Allow Fish-like user contributed completions.
fpath=($__zsh_config_dir/completions(-/FN) $fpath)

# Print the completion directories compaudit objects to, and how to fix them.
# compinit -i skips them silently, and asking instead would stall a shell that
# has no terminal to answer with.
function zephyr-compaudit-warn {
  emulate -L zsh
  autoload -Uz compaudit

  local -a insecure=(${(f)"$(compaudit 2>/dev/null)"})
  (( $#insecure )) || return 0

  print -u2 "zephyr: ignoring insecure completion directories:"
  print -lu2 -- $insecure
  print -u2 "zephyr: fix by running: compaudit | xargs chmod g-w,o-w"
}

function run_compinit {
  emulate -L zsh
  setopt local_options extended_glob

  # Use ZSH_COMPDUMP for the completion file.
  typeset -g ZSH_COMPDUMP
  if [[ -z "$ZSH_COMPDUMP" ]]; then
    if zstyle -T ':zephyr:plugin:completion' use-xdg-basedirs; then
      ZSH_COMPDUMP=$__zsh_cache_dir/zcompdump
    else
      ZSH_COMPDUMP=$HOME/.zcompdump
    fi
  fi

  # Make sure ZSH_COMPDUMP's directory exists and doesnt' have a leading tilde.
  ZSH_COMPDUMP="${~ZSH_COMPDUMP}"
  [[ -d $ZSH_COMPDUMP:h ]] || mkdir -p $ZSH_COMPDUMP:h

  # `run_compinit -f` forces a cache reset.
  if [[ "$1" == (-f|--force) ]]; then
    shift
    [[ -r "$ZSH_COMPDUMP" ]] && rm -rf -- "$ZSH_COMPDUMP"
  fi

  # compinit flags: https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Use-of-compinit
  # -C        : Omit the check for new completion functions
  # -i        : Ignore insecure directories in fpath
  # -u        : Allow insecure directories in fpath
  # -d <file> : Specify zcompdump file
  local -a compinit_flags=(-i)
  if zstyle -t ':zephyr:plugin:completion' 'disable-compfix'; then
    compinit_flags=(-u)
  fi
  compinit_flags+=(-d "$ZSH_COMPDUMP")

  # Initialize completions
  autoload -Uz compinit
  if zstyle -t ':zephyr:plugin:completion' 'use-cache'; then
    # Cache for 20 hours, so it regenerates the first time a shell opens each day.
    # A changed fpath also has to invalidate, or new completions stay missing for
    # those 20 hours. Stamp fpath before compinit, since -i prunes insecure dirs
    # from it and the next startup would never match a post-compinit stamp.
    local stampfile=$ZSH_COMPDUMP.fpath stamped= wanted="$fpath"
    [[ -r $stampfile ]] && stamped="$(<$stampfile)"
    [[ "$wanted" == "$stamped" ]] || command rm -f "$ZSH_COMPDUMP" "$ZSH_COMPDUMP.zwc"

    if [[ -n $ZSH_COMPDUMP(#qNmh-20) ]]; then
      compinit -C $compinit_flags
    else
      compinit $compinit_flags
      print -r -- "$wanted" >| $stampfile
      touch "$ZSH_COMPDUMP"  # Ensure timestamp updates to reset the cache timeout.
    fi
  else
    compinit $compinit_flags
  fi

  if [[ "$compinit_flags[1]" == -i ]] && ! zstyle -t ':zephyr:plugin:completion:compaudit' quiet; then
    zephyr-compaudit-warn &!
  fi

  # Recompiles only if stale, and renames atomically, so concurrent shells are safe.
  autoload -Uz zrecompile
  zrecompile -q -p "$ZSH_COMPDUMP" &!
}

# Let's talk about compinit for a second...
# compinit works by finding _completion files in your fpath. That means fpath needs to
# be fully populated prior to calling it. But sometimes you need to call compdef before
# fpath is done being populated (eg: plugins do this). compinit has big chicken-and-egg
# problems. This code handles all those completion use-cases by wrapping compinit,
# queueing any calls to compdef, and hooking the real call to compinit to Zephyr's
# custom post_zshrc event.

# Define compinit placeholder functions (compdef) so we can queue up calls.
# That way when the real compinit is called, we can execute the queue.
typeset -gHa __compdef_queue=()
function compdef {
  (( $# )) && __compdef_queue+=("${(j: :)${(@q+)@}}")
}

# Wrap compinit temporarily so that when the real compinit call happens, the
# queue of compdef calls is processed.
function compinit {
  unfunction compinit compdef &>/dev/null
  autoload -Uz compinit && compinit "$@"

  # Apply all the queued compdefs.
  local entry
  for entry in "${__compdef_queue[@]}"; do
    eval "compdef $entry"
  done
  unset __compdef_queue

  # We can run compinit early, and if we did we no longer need a post_zshrc hook.
  post_zshrc_hook=(${post_zshrc_hook:#run_compinit})
}

# Set the completion style
zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
if (( $+functions[compstyle_${zcompstyle}_setup] )); then
  compstyle_${zcompstyle}_setup
elif [[ "$zcompstyle" != none ]]; then
  compstyleinit
  compstyle ${zcompstyle}
fi
unset zcompstyle

# Allow the user to bypass the compinit deferral and run it immediately. Otherwise, we
# hook run_compinit to the custom post_zshrc event.
if zstyle -t ':zephyr:plugin:completion' immediate; then
  run_compinit || return 1
else
  add-post-zshrc-hook run_compinit
fi

#region MARK LOADED
zstyle ':zephyr:plugin:completion' loaded 'yes'
#endregion
