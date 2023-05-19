#
# history - Set history options and define history aliases.
#

() {
  local histopts=(
    # 16.2.4 History
    bang_hist               # Treat the '!' character specially during expansion.
    extended_history        # Write the history file in the ':start:elapsed;command' format.
    hist_expire_dups_first  # Expire a duplicate event first when trimming history.
    hist_find_no_dups       # Do not display a previously found event.
    hist_ignore_all_dups    # Delete an old recorded event if a new event is a duplicate.
    hist_ignore_dups        # Do not record an event that was just recorded again.
    hist_ignore_space       # Do not record an event starting with a space.
    hist_reduce_blanks      # Remove extra blanks from commands added to the history list.
    hist_save_no_dups       # Do not write a duplicate event to the history file.
    hist_verify             # Do not execute immediately upon history expansion.
    inc_append_history      # Write to the history file immediately, not when the shell exits.
    NO_hist_beep            # Don't beep when accessing non-existent history.
    NO_share_history        # Don't share history between all sessions.
  )
  setopt $histopts

  # The path to the history file.
  zstyle -s ':zephyr:plugin:history' histfile 'HISTFILE' ||
    HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history"
  [[ -d $HISTFILE:h ]] || mkdir -p $HISTFILE:h

  # remove in the future
  if [[ -f ${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history ]] &&
     [[ ! -f ${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history ]]
  then
    cp ${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history ${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history
  fi

  # Session history items, and history file items
  zstyle -s ':zephyr:plugin:history' histsize 'HISTSIZE' ||
    HISTSIZE=10000
  zstyle -s ':zephyr:plugin:history' savehist 'SAVEHIST' ||
    SAVEHIST=10000

  #
  # Aliases
  #

  if ! zstyle -t ':zshzoo:history:alias' skip; then
    alias hist='fc -li'
    alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"
  fi

  #
  # Wrap up
  #

  # Tell Zephyr this plugin is loaded.
  zstyle ':zephyr:plugin:history' loaded 'yes'
}
