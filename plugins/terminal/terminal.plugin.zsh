#
# set terminal window and tab titles
#

# return if requirements are not found
if [[ "$TERM" == (dumb|linux|*bsd*|eterm*) ]]; then
  return 1
fi

# sets the terminal window title
function set-window-title {
  local title_format{,ted}
  title_format="%s"
  zformat -f title_formatted "$title_format" "s:$argv"
  printf '\e]2;%s\a' "${(V%)title_formatted}"
}

# sets the terminal tab title
function set-tab-title {
  local title_format{,ted}
  title_format="%s"
  zformat -f title_formatted "$title_format" "s:$argv"
  printf '\e]1;%s\a' "${(V%)title_formatted}"
}

# sets the terminal multiplexer tab title
function set-multiplexer-title {
  local title_format{,ted}
  title_format="%s"
  zformat -f title_formatted "$title_format" "s:$argv"
  printf '\ek%s\e\\' "${(V%)title_formatted}"
}

# sets the tab and window titles with a given command
function _terminal-set-titles-with-command {
  emulate -L zsh
  setopt EXTENDED_GLOB

  # get the command name that is under job control
  if [[ "${2[(w)1]}" == (fg|%*)(\;|) ]]; then
    # get the job name, and, if missing, set it to the default %+
    local job_name="${${2[(wr)%*(\;|)]}:-%+}"

    # make a local copy for use in the subshell
    local -A jobtexts_from_parent_shell
    jobtexts_from_parent_shell=(${(kv)jobtexts})

    jobs "$job_name" 2> /dev/null > >(
      read index discarded
      # the index is already surrounded by brackets: [1]
      _terminal-set-titles-with-command "${(e):-\$jobtexts_from_parent_shell$index}"
    )
  else
    # set the command name, or in the case of sudo or ssh, the next command
    local cmd="${${2[(wr)^(*=*|sudo|ssh|-*)]}:t}"
    local truncated_cmd="${cmd/(#m)?(#c15,)/${MATCH[1,12]}...}"
    unset MATCH

    if [[ "$TERM" == screen* ]]; then
      set-multiplexer-title "$truncated_cmd"
    fi
    set-tab-title "$truncated_cmd"
    set-window-title "$cmd"
  fi
}

# sets the tab and window titles with a given path
function _terminal-set-titles-with-path {
  emulate -L zsh
  setopt EXTENDED_GLOB

  local absolute_path="${${1:a}:-$PWD}"
  local abbreviated_path="${absolute_path/#$HOME/~}"
  local truncated_path="${abbreviated_path/(#m)?(#c15,)/...${MATCH[-12,-1]}}"
  unset MATCH

  if [[ "$TERM" == screen* ]]; then
    set-multiplexer-title "$truncated_path"
  fi
  set-tab-title "$truncated_path"
  set-window-title "$abbreviated_path"
}

# do not override precmd/preexec; append to the hook array
autoload -Uz add-zsh-hook

# set up the Apple Terminal
if [[ "$TERM_PROGRAM" == 'Apple_Terminal' ]] \
  && ( ! [[ -n "$STY" || -n "$TMUX" || -n "$DVTM" ]] )
then
  # sets the Terminal.app current working directory before the prompt is
  # displayed
  function _terminal-set-terminal-app-proxy-icon {
    printf '\e]7;%s\a' "file://${HOST}${PWD// /%20}"
  }
  add-zsh-hook precmd _terminal-set-terminal-app-proxy-icon

  # unsets the Terminal.app current working directory when a terminal
  # multiplexer or remote connection is started since it can no longer be
  # updated, and it becomes confusing when the directory displayed in the title
  # bar is no longer synchronized with real current working directory
  function _terminal-unset-terminal-app-proxy-icon {
    if [[ "${2[(w)1]:t}" == (screen|tmux|dvtm|ssh|mosh) ]]; then
      print '\e]7;\a'
    fi
  }
  add-zsh-hook preexec _terminal-unset-terminal-app-proxy-icon

  # do not set the tab and window titles in Terminal.app since it sets the tab
  # title to the currently running process by default and the current working
  # directory is set separately
  return
fi

# set up non-Apple terminals
if ! [[ -n "$STY" || -n "$TMUX" ]]
then
  # sets titles before the prompt is displayed
  add-zsh-hook precmd _terminal-set-titles-with-path

  # sets titles before command execution
  add-zsh-hook preexec _terminal-set-titles-with-command
fi
