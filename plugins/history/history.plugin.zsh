#
# history - Set history options and define history aliases.
#
# THIS FILE IS GENERATED:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/history/init.zsh
#

#
# Options
#

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_REDUCE_BLANKS        # Remove extra blanks from commands added to the history list.
unsetopt HIST_BEEP               # Do not beep when accessing non-existent history.
unsetopt SHARE_HISTORY           # Don't share history between all sessions.

#
# Variables
#

zstyle -s ':zephyr:plugin:history' histfile '_histfile' || _histfile="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
zstyle -s ':zephyr:plugin:history' histsize '_histsize' || _histsize=10000
zstyle -s ':zephyr:plugin:history' savehist '_savehist' || _savehist=10000
HISTFILE="${_histfile}"  # The path to the history file.
HISTSIZE="${_histsize}"  # The maximum number of events to save in the internal history.
SAVEHIST="${_savehist}"  # The maximum number of events to save in the history file.
unset _{hist{file,size},savehist}

# Make sure the path to the history file exists.
[[ -f $HISTFILE ]] || mkdir -p $HISTFILE:h

#
# Aliases
#

if ! zstyle -t ':zephyr:plugin:history:alias' skip; then
  # Lists the ten most used commands.
  alias history-stat="command history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"
  alias hist='fc -li'
fi


#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:history' loaded 'yes'
