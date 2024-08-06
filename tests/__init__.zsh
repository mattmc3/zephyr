#!/bin/zsh
##? substenv - substitutes string parts with environment variables
function substenv {
  local -a args=($@)
  (( $#args )) || args=(HOME)
  local -a sedargs=()
  local argv
  for argv in $args; do
    sedargs+=('-e' "s|${(P)argv}|\$${argv}|g")
  done
  sed -E "${sedargs[@]}"
}

function collect-input {
  local -a input=()
  if (( $# > 0 )); then
    input=("${(s.\n.)${@}}")
  elif [[ ! -t 0 ]]; then
    local data
    while IFS= read -r data || [[ -n "$data" ]]; do
      input+=("$data")
    done
  fi
  printf '%s\n' "${input[@]}"
}

function string-escape {
  local -a input=("${(@f)$(collect-input "$@")}")
  print -lr ${(qqqq)input[@]} | sed -e 's/\\033/\\e\\/g' -e 's/ /\\ /g' | tr -d "$'"
}

function t_setup {
  0=${(%):-%x}

  # save zstyles, and clear them all for the test session
  typeset -ga T_PREV_ZSTYLES=( ${(@f)"$(zstyle -L ':zephyr:*')"} )
  source <(zstyle -L ':zephyr:*' | awk '{print "zstyle -d",$2}')

  # works with BSD and GNU gmktemp
  typeset -gx T_TEMPDIR=${$(mktemp -d -t t_zephyr.XXXXXXXX):A}
  typeset -gx OLD_HOME=$HOME
  typeset -gx HOME=$T_TEMPDIR
  mkdir -p $T_TEMPDIR/.zsh

  # save fpath, aliases, funcs, environment
  typeset -g T_PREV_FPATH=( $fpath )
  typeset -ga T_PREV_ALIASES=( ${(k)aliases} )
  typeset -ga T_PREV_FUNCS=( ${(k)functions} )
  typeset -gA T_PREV_ZOPTS=( $(set -o) )
  typeset -ga T_PREV_PARAMS=( $(typeset -px | awk -F '=' '{print $1}' | awk '{print $NF}') )

  zsh -df -c "set -o" >| $T_TEMPDIR/zsh_default.opts
}

function t_teardown {
  # emulate -L zsh
  # setopt local_options

  # reset current session
  ZDOTDIR=$OLD_ZDOTDIR

  # reset Zsh opts
  local -A zopts=( $(set -o) )
  local zopt zoptval
  for zopt zoptval in ${(kv)zopts}; do
    if [[ $T_PREV_ZOPTS[$zopt] != $zoptval ]]; then
      [[ $zoptval == on ]] && unsetopt $zopt || setopt $zopt
    fi
  done

  local aliasname
  for aliasname in ${(k)aliases}; do
    (( $T_PREV_ALIASES[(Ie)$aliasname] )) || unalias -- $aliasname
  done
  local funcname
  for funcname in ${(k)functions}; do
    (( $T_PREV_FUNCS[(Ie)$funcname] )) || unfunction -- $funcname
  done
  local paramname params=( $(typeset -px | awk -F '=' '{print $1}' | awk '{print $NF}') )
  for paramname in $params; do
    (( $T_PREV_PARAMS[(Ie)$paramname] )) || unset $paramname
  done
  for varname in post_zshrc; do
    unset $varname &>/dev/null
  done

  # restore original fpath
  fpath=( $T_PREV_FPATH )

  # restore original zstyles
  source <(zstyle -L ':zephyr:*' | awk '{print "zstyle -d",$2}')
  source <(printf '%s\n' $T_PREV_ZSTYLES)

  # remove tempdir
  if [[ -d "$T_TEMPDIR" ]] && [[ ${T_TEMPDIR:A} =~ '/(var|tmp)/*' ]]; then
    rm -rf $T_TEMPDIR
  else
    echo "WARNING: \$T_TEMPDIR not found: '$T_TEMPDIR'"
  fi
  typeset -gx HOME=$OLD_HOME

  unset T_TEMPDIR OLD_HOME T_PREV_{ALIASES,FPATH,FUNCS,PARAMS,ZOPTS}
}

function t_reset {
  t_teardown
  t_setup
}

function t_mock_source {
  if (( $# == 0 )); then
    echo >&2 "mock source: not enough arguments"
    return 1
  fi
  local srcfile
  for srcfile in $@; do
    # if the file lives in $ZDOTDIR, don't really source it
    if [[ "$srcfile" =~ "$T_TEMPDIR/"* ]] then
      if [[ -r "$srcfile" ]]; then
        echo "mock sourcing file... $srcfile"
      else
        echo >&2 "mock source: no such file or directory: $srcfile"
        return 1
      fi
    else
      . "$srcfile"
    fi
  done
}

function t_setup_rc_files {
  local files=(
    # zsh files
    a.zsh
    b.zsh

    # sh files
    b.sh
    c.sh

    # skip files
    '.hidden.zsh'
    '~skipme.zsh'
    'wrongshell.bash'
  )

  local f fp
  for f in $files; do
    fp=${1:-$T_TEMPDIR/.zshrc.d}/${f}
    [[ -d "${fp:h}" ]] || mkdir -p ${fp:h}
    echo "echo 'sourced file:' '${fp}'" >| ${fp}
  done
  echo "echo 'sourced file:' '$T_TEMPDIR/foo.zsh'" >| $T_TEMPDIR/foo.zsh
  ln -s $T_TEMPDIR/foo.zsh ${1:-$T_TEMPDIR/.zshrc.d}/sym.zsh
}
