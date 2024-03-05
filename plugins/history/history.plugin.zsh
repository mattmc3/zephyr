#
# history - Set history options and define history aliases.
#

# References:
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/history
# - https://zsh.sourceforge.io/Doc/Release/Options.html#History

# Set Zsh history options.
# 16.2.4: https://zsh.sourceforge.io/Doc/Release/Options.html#History
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

# Set the path to the history file.
zstyle -s ':zephyr:plugin:history' histfile '_zhistfile'
if [[ -z "$_zhistfile" ]]; then
  if zstyle -T ':zephyr:plugin:history' use-xdg-basedirs; then
    _zhistfile=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history
  else
    _zhistfile=${ZDOTDIR:-$HOME}/.zsh_history
  fi
fi
_zhistfile=${~_zhistfile}
[[ -d $_zhistfile:h ]] || mkdir -p $_zhistfile:h
HISTFILE=$_zhistfile
unset _zhistfile

# Set history file size (default 1000).
zstyle -s ':zephyr:plugin:history' savehist 'SAVEHIST' ||
  SAVEHIST=100000

# Set session history size (default: 2000).
zstyle -s ':zephyr:plugin:history' histsize 'HISTSIZE' ||
  HISTSIZE=20000

# Set Zsh aliases related to history.
if ! zstyle -t ':zephyr:plugin:history:alias' skip; then
  alias hist='fc -li'
  alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"
fi

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:history' loaded 'yes'
