#region HEADER
#
# history: Set history options and define history aliases.
#

# References:
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/history
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
# - https://zsh.sourceforge.io/Doc/Release/Options.html#History

0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
#endregion

# Set Zsh options related to history.
setopt bang_hist               # Treat the '!' character specially during expansion.
setopt extended_history        # Write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first  # Expire a duplicate event first when trimming history.
setopt hist_find_no_dups       # Do not display a previously found event.
setopt hist_ignore_all_dups    # Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_dups        # Do not record an event that was just recorded again.
setopt hist_ignore_space       # Do not record an event starting with a space.
setopt hist_reduce_blanks      # Remove extra blanks from commands added to the history list.
setopt hist_save_no_dups       # Do not write a duplicate event to the history file.
setopt hist_verify             # Do not execute immediately upon history expansion.
setopt inc_append_history      # Write to the history file immediately, not when the shell exits.
setopt NO_hist_beep            # Don't beep when accessing non-existent history.
setopt NO_share_history        # Don't share history between all sessions.

# Set the path to the default history file.
if zstyle -s ':zephyr:plugin:history' histfile 'HISTFILE'; then
  # Make sure the user didn't store a HISTFILE with a leading '~'.
  HISTFILE=${~HISTFILE}
else
  if zstyle -T ':zephyr:plugin:history' use-xdg-basedirs; then
    HISTFILE="${__zsh_user_data_dir}/zsh_history"
  else
    HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
  fi
fi

# Make sure the HISTFILE's directory exists.
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# Set the history file and session sizes. HISTSIZE and SAVEHIST always have a value
# in Zsh, so absent a zstyle these only grow, and never shrink a larger existing
# value.
[[ "$SAVEHIST" -gt 100000 ]] || SAVEHIST=100000
[[ "$HISTSIZE" -gt  20000 ]] || HISTSIZE=20000

# A zstyle wins outright. Assign via a temp, because `zstyle -s` empties its target
# variable when the style isn't set.
zstyle -s ':zephyr:plugin:history' savehist '_zph_val' && SAVEHIST=$_zph_val
zstyle -s ':zephyr:plugin:history' histsize '_zph_val' && HISTSIZE=$_zph_val
unset _zph_val

# Set history aliases.
if ! zstyle -t ':zephyr:plugin:history:alias' skip; then
  alias hist='fc -li'
  alias histsync='fc -RI'
  alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"
fi

# Use auxiliary history backends if enabled.
if zstyle -t ':zephyr:plugin:history:aux:sqlite' enable \
   || zstyle -t ':zephyr:plugin:history:aux:json' enable; then
  source ${0:a:h}/lib/aux_common.zsh
fi

#region MARK LOADED
zstyle ':zephyr:plugin:history' loaded 'yes'
#endregion
