#region HEADER
#
# fishify: Commands and features to make Zsh feel more fish-like.
#

0=${(%):-%N}
path+=("${0:a:h}/bin")

function or {
  local err=$?
  if [[ "$#" -eq 0 ]]; then
    print -ru2 "or: Expected a command, but found end of the statement"
    return 2
  fi
  if [[ $err -ne 0 ]]; then
    $@
  else
    return $err
  fi
}

function and {
  local err=$?
  if [[ "$#" -eq 0 ]]; then
    print -ru2 "and: Expected a command, but found end of the statement"
    return 2
  fi
  if [[ $err -eq 0 ]]; then
    $@
  else
    return $err
  fi
}

function not {
  $@
  [[ $? -eq 0 ]] && return 1 || return 0
}

#region MARK LOADED
zstyle ':zephyr:plugin:fishy' loaded 'yes'
#endregion
