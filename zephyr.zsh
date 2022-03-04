#
# Variables
#

ZEPHYRDIR=${0:A:h}

#
# Functions
#

function autoad_funcdir {
  [[ -d "$1" ]] || return 1
  fpath+="$1"
  local fn
  for fn in "$1"/*(.N); do
    autoload -Uz $fn
  done
}

function _zephyr_clone {
  local repo=$1
  local name=${2:-${1:t}}
  local dest=$ZEPHYRDIR/contribs/$name

  # clone the plugin if we don't find it
  if [[ ! -d $dest ]]; then
    echo "Cloning plugin $repo..."
    git clone --quiet --depth 1 --recursive --shallow-submodules https://github.com/$repo $dest

    local initfile=$dest/${name}.plugin.zsh
    if [[ ! -e $initfile ]]; then
      local initfiles=($dest/*.plugin.{z,}sh(N) $dest/*.{z,}sh(N))
      (( $#initfiles )) && ln -sf ${initfiles[1]} $initfile
    fi
    local promptfile=$dest/prompt_${name}_setup
    if [[ ! -e $promptfile ]]; then
      local promptfiles=($dest/*.zsh-theme(N))
      (( $#promptfiles )) && echo ". ${promptfiles[1]}" >| $promptfile
    fi
  fi
}

function _zephyr_help {
  local usage=(
    'zephyr - A Zsh framework as nice as a cool summer breeze'
    ''
    'usage:'
    '  zephyr <command> [<flags...>|<arguments...>]'
    ''
    'commands:'
    '  help     show this message'
    '  init     initialize zephyr'
    '  reset    reset the init'
    '  clean    remove cloned plugins and other cache files'
    '  update   update zephyr and its plugins'
  )
  printf "%s\n" "${usage[@]}"
}

function _zephyr_init {
  local dflt_pluginsfile=${ZDOTDIR:-$HOME}/.zephyr.plugins
  local pluginsfile="${1:-$dflt_pluginsfile}"

  # make a basic plugins file if none specified and the default file not found
  if [[ -z "$1" ]] && [[ ! -f "$dflt_pluginsfile" ]]; then
    command cp $ZEPHYRDIR/misc/default.plugins "$dflt_pluginsfile"
  fi

  if [[ ! -f $pluginsfile ]]; then
    echo >&2 "zephyr: plugins file not found '$1'."
    return 1
  fi

  # check the viability of the current init.zsh file
  __zephyr_checkfile $pluginsfile || _zephyr_reset $pluginsfile

  source $ZEPHYRDIR/.cache/init.zsh
}

function __zephyr_checkfile {
  [[ -f $1 ]] || return 1
  local chkfile=$ZEPHYRDIR/.cache/init.chk

  local ZEPHYR_INIT_AGE ZEPHYR_INIT_CKSUM
  [[ -f $chkfile ]] && source $chkfile

  local cur_age cur_cksum chkcontents
  cur_age="$(stat -Lc "%Y" 2>/dev/null $1 || \
             stat -Lf "%m" 2>/dev/null $1)"
  cur_cksum="$(cksum $1)"

  if [[ $cur_age != $ZEPHYR_INIT_AGE ]] ||
     [[ $cur_cksum != $ZEPHYR_INIT_CKSUM ]]
  then
    chkcontents=(
      "ZEPHYR_INIT_AGE='$cur_age'"
      "ZEPHYR_INIT_CKSUM='$cur_cksum'"
    )
    mkdir -p "${chkfile:h}"
    printf "%s\n" $chkcontents >| $chkfile
    return 1
  fi
}

function _zephyr_reset {
  local pluginsfile=$1

  zmodload zsh/mapfile
  local lines=( "${(f)mapfile[$pluginsfile]}" )
  local line parts plugin optstr opts name instructions deferred=0
  typeset -A opts
  typeset -a instructions=()

  for line in $lines; do
    [[ $line != \#* ]] || continue
    # split the plugin from the options and store opts in a lookup
    # this is done by splitting on space and then colons
    parts=(${(@s/ /)line})
    plugin=$parts[1]
    optstr=(${parts[@]:1})
    opts=(${(@s/:/)optstr})
    name=${opts[name]:-${plugin:t}}
    loc=plugins

    # git repos vs regular plugins are identified simply by whether they contain a slash
    if [[ $plugin = */* ]]; then
      _zephyr_clone $plugin $name
      loc=contribs
    fi

    if [[ $opts[kind] = clone ]]; then
      # nothing else to do on clone only plugins
      continue
    elif [[ $opts[kind] = prompt ]] || [[ $opts[kind] = fpath ]]; then
      instructions+="fpath+=\$ZEPHYRDIR/$loc/$name"
    elif [[ $opts[kind] = path ]]; then
      instructions+="path+=\$ZEPHYRDIR/$loc/$name"
    elif [[ $opts[kind] = defer ]]; then
      deferred=1
      instructions+="fpath+=\$ZEPHYRDIR/$loc/$name"
      instructions+="zsh-defer source \$ZEPHYRDIR/$loc/$name/$name.plugin.zsh"
    else
      instructions+="fpath+=\$ZEPHYRDIR/$loc/$name"
      instructions+="source \$ZEPHYRDIR/$loc/$name/$name.plugin.zsh"
    fi
  done

  if [[ $deferred = 1 ]]; then
    [[ -d $ZEPHYRDIR/contribs/zsh-defer ]] || _zephyr_clone romkatv/zsh-defer
    instructions=(
      "fpath+=\$ZEPHYRDIR/contribs/zsh-defer"
      "source \$ZEPHYRDIR/contribs/zsh-defer/zsh-defer.plugin.zsh"
      $instructions
    )
  fi

  [[ -d $ZEPHYRDIR/.cache ]] || mkdir -p $ZEPHYRDIR/.cache
  printf "%s\n" $instructions >| $ZEPHYRDIR/.cache/init.zsh
}

function _zephyr_clean {
  [[ ! -d "$ZEPHYRDIR/contribs" ]] || command rm -rf "$ZEPHYRDIR/contribs"
  [[ ! -d "$ZEPHYRDIR/.cache" ]] || command rm -rf "$ZEPHYRDIR/.cache"
}

function _zephyr_update {
  local d
  for d in $ZEPHYRDIR/**/.git/..; do
    echo "Updating ${d:A:t}..."
    git -C "${d:A}" pull --ff --rebase --autostash
  done
}

function zephyr {
  0=${(%):-%x}
  ZEPHYRDIR=${ZEPHYRDIR:-$0:A:h}
  local cmd="$1"

  if (( $+functions[_zephyr_${cmd}] )); then
    shift
    _zephyr_${cmd} "$@"
    return $?
  elif [[ -z "$cmd" ]] || [[ $cmd = --help ]] || [[ $cmd = -h ]]; then
    _zephyr_help
  else
    echo >&2 "zephyr: command not found '${cmd}'" && return 1
  fi
}
