function zephyr_color {
  #
  # color: Make the terminal more colorful.
  #

  # Return if requirements are not found.
  [[ "$TERM" != 'dumb' ]] || return 1

  # Built-in zsh colors.
  autoload -Uz colors && colors

  # Colorize man pages.
  export LESS_TERMCAP_md=$fg_bold[blue]   # start bold
  export LESS_TERMCAP_mb=$fg_bold[blue]   # start blink
  export LESS_TERMCAP_so=$'\e[00;47;30m'  # start standout: white bg, black fg
  export LESS_TERMCAP_us=$'\e[04;35m'     # start underline: underline magenta
  export LESS_TERMCAP_se=$reset_color     # end standout
  export LESS_TERMCAP_ue=$reset_color     # end underline
  export LESS_TERMCAP_me=$reset_color     # end bold/blink

  # Set LS_COLORS using (g)dircolors if found.
  if [[ -z "$LS_COLORS" ]]; then
    for dircolors_cmd in dircolors gdircolors; do
      if (( $+commands[$dircolors_cmd] )); then
        if zstyle -t ':zephyr:plugin:color' 'use-cache'; then
          cached-eval "$dircolors_cmd" $dircolors_cmd --sh
        else
          source <($dircolors_cmd --sh)
        fi
        break
      fi
    done
    # Or, pick a reasonable default.
    export LS_COLORS="${LS_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
  fi

  # Missing dircolors is a good indicator of a BSD system. Set LSCOLORS for macOS/BSD.
  if (( ! $+commands[dircolors] )); then
    # For BSD systems, set LSCOLORS
    export CLICOLOR=${CLICOLOR:-1}
    export LSCOLORS="${LSCOLORS:-exfxcxdxbxGxDxabagacad}"
  fi

  # https://github.com/romkatv/powerlevel10k/blob/8fefef228571c08ce8074d42304adec3b0876819/config/p10k-lean.zsh#L6C5-L6C105
  ##? Show a simple colormap
  function colormap {
    for i in {0..255}; do
      print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
    done
  }

  # Set colors for grep.
  alias grep="${aliases[grep]:-grep} --color=auto"

  # Set colors for coreutils ls.
  alias ls="${aliases[ls]:-ls} --color=auto"
  if (( $+commands[gls] )); then
    alias gls="${aliases[gls]:-gls} --color=auto"
  fi

  # Set colors for diff
  if command diff --color /dev/null{,} &>/dev/null; then
    alias diff="${aliases[diff]:-diff} --color"
  fi

  # Colorize completions.
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:color' loaded 'yes'
}

function zephyr_completion {
  function compstyle_zephyr_setup {
    #!/bin/zsh

    function compstyle_zephyr_help {
      local -a help
      help=(
        'A composite of the grml, prezto, and ohmyzsh completions.'
        'You can invoke it with the following command:'
        ''
        '  compstyle zephyr'
        ''
        'More information available here: https://github.com/mattmc3/zephyr'
      )
      printf '%s\n' "${help[@]}"
    }

    function compstyle_zephyr_setup {
      # Pre-reqs.
      : ${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}
      [[ -d $__zsh_cache_dir ]] || mkdir -p $__zsh_cache_dir

      # Standard style used by default for 'list-colors'
      LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}

      # Defaults.
      zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
      zstyle ':completion:*:default' list-prompt '%S%M matches%s'

      # Use caching to make completion for commands such as dpkg and apt usable.
      zstyle ':completion::complete:*' use-cache on
      zstyle ':completion::complete:*' cache-path "$__zsh_cache_dir/zcompcache"

      # Case-insensitive (all), partial-word, and then substring completion.
      if zstyle -t ':zephyr:plugin:completion:*' case-sensitive; then
        zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
        setopt case_glob
      else
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
        unsetopt case_glob
      fi

      # Group matches and describe.
      zstyle ':completion:*:*:*:*:*' menu select
      zstyle ':completion:*:matches' group 'yes'
      zstyle ':completion:*:options' description 'yes'
      zstyle ':completion:*:options' auto-description '%d'
      zstyle ':completion:*:corrections' format ' %F{red}-- %d (errors: %e) --%f'
      zstyle ':completion:*:descriptions' format ' %F{purple}-- %d --%f'
      zstyle ':completion:*:messages' format ' %F{green} -- %d --%f'
      zstyle ':completion:*:warnings' format ' %F{yellow}-- no matches found --%f'
      zstyle ':completion:*' format ' %F{blue}-- %d --%f'
      zstyle ':completion:*' group-name ''
      zstyle ':completion:*' verbose yes

      # Fuzzy match mistyped completions.
      zstyle ':completion:*' completer _complete _match _approximate
      zstyle ':completion:*:match:*' original only
      zstyle ':completion:*:approximate:*' max-errors 1 numeric

      # Increase the number of errors based on the length of the typed word. But make
      # sure to cap (at 7) the max-errors to avoid hanging.
      zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

      # Don't complete unavailable commands.
      zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

      # Array completion element sorting.
      zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

      # Directories
      zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
      zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
      zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
      zstyle ':completion:*' squeeze-slashes true
      zstyle ':completion:*' special-dirs ..

      # History
      zstyle ':completion:*:history-words' stop yes
      zstyle ':completion:*:history-words' remove-all-dups yes
      zstyle ':completion:*:history-words' list false
      zstyle ':completion:*:history-words' menu yes

      # Environment Variables
      zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

      # Populate hostname completion. But allow ignoring custom entries from static
      # */etc/hosts* which might be uninteresting.
      zstyle -a ':zephyr:plugin:completion:*:hosts' etc-host-ignores '_etc_host_ignores'

      zstyle -e ':completion:*:hosts' hosts 'reply=(
        ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
        ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
        ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
      )'

      # Don't complete uninteresting users...
      zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

      # ... unless we really want to.
      zstyle '*' single-ignored show

      # Ignore multiple entries.
      zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
      zstyle ':completion:*:rm:*' file-patterns '*:all-files'

      # Kill
      zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
      zstyle ':completion:*:*:kill:*' menu yes select
      zstyle ':completion:*:*:kill:*' force-list always
      zstyle ':completion:*:*:kill:*' insert-ids single

      # Man
      zstyle ':completion:*:manuals' separate-sections true
      zstyle ':completion:*:manuals.(^1*)' insert-sections true
      zstyle ':completion:*:man:*' menu yes select

      # Media Players
      zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
      zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
      zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
      zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

      # Mutt
      if [[ -s "$HOME/.mutt/aliases" ]]; then
        zstyle ':completion:*:*:mutt:*' menu yes select
        zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
      fi

      # SSH/SCP/RSYNC
      zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
      zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
      zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
      zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
      zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
      zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
    }
    compstyle_zephyr_setup "$@"
  }

  function compstyleinit {
    #!/bin/zsh
    #
    # zsh completions styles extension
    #
    # Load with `autoload -Uz compstyleinit; compstyleinit'.
    # Type `compstyle -h' for help.
    #

    typeset -gaU completion_styles
    typeset -ga completion_style
    completion_styles=()

    function compstyleinit {
      emulate -L zsh; setopt extendedglob

      local name setupfn
      local -a match

      # Autoload all compstyle_*_setup functions in fpath.
      for setupfn in $^fpath/compstyle_*_setup(N); do
        if [[ $setupfn == */compstyle_(#b)(*)_setup ]]; then
          name="$match[1]"
          if [[ -r "$setupfn" ]]; then
            completion_styles=($completion_styles $name)
            autoload -Uz compstyle_${name}_setup
          else
            print "Cannot read '$setupfn' file containing completion styles."
          fi
        else
          print "Unexpect compstyle setup function '$setupfn'."
        fi
      done
    }

    function _compstyle_usage {
      emulate -L zsh; setopt extended_glob
      0=${(%):-%x}
      local usage='Usage: compstyle [-l] [-h [<style>]]
           compstyle <style>
    Options:
      -l            List currently available completion styles
      -h [<style>]  Display help (for given compstyle)
    Arguments:
      <style>       Switch to new compstyle

    Use `compstyle -h` for help.
    Load with `autoload -Uz compstyleinit; compstyleinit`.
    Set completion style with `compstyle <compstyle>`.'

      if [[ -n "$1" && -n "$completion_styles[(r)$1]" ]]; then
        # Run this in a subshell, so we don't need to clean up afterwards.
        (
          # If we can't find a _help function, run the _setup function to see
          # if it will create one.
          (( $+functions[compstyle_$1_help] )) || compstyle_$1_setup

          # ...then try again.
          if (( $+functions[compstyle_$1_help] )); then
            print "Help for '$1' completion style:\n"
            compstyle_$1_help
          else
            print "No help available for '$1' completion style."
          fi
        )
      else
        # read '##?' doc comments from this file to display usage
        print $usage
      fi
    }

    function compstyle {
      # compstyle [-l] [-h [<style>]]
      local opt
      while getopts 'lh' opt; do
        case "$opt" in
          l) print Currently available completion styles:
             print $completion_styles
             return
             ;;
          h) _compstyle_usage "$@[2,-1]"; return $? ;;
          *) _compstyle_usage;            return 2  ;;
        esac
      done

      # error if compstyle specified not found
      if [[ -z "$1" || -z $completion_styles[(r)$1] ]]; then
        print >&2 "compstyle: Completion style not found '$1'."
        _compstyle_usage
        return 1
      fi

      # TODO: cleanup any prior completion styles

      # set the new completion styles
      compstyle_$1_setup "$@[2,-1]" && completion_style=( "$@" )
    }

    compstyleinit "$@"

    # vim: ft=zsh sw=2 ts=2 et
  }

  function run-compinit {
    #!/bin/zsh
    #
    # run-compinit - run compinit in a smarter, faster way
    #

    #function run-compinit {
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

      # `run-compinit -f` forces a cache reset.
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
    #}
  }

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

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  # Load plugin functions.
  0=${(%):-%N}
  fpath=(${0:a:h}/functions $fpath)
  autoload -Uz ${0:a:h}/functions/*(.:t)

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
    run-compinit
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
      run-compinit
      hooks-add-hook -d post_zshrc run-compinit-post-zshrc
    }
    hooks-add-hook post_zshrc run-compinit-post-zshrc
  fi

  # Set the completion style
  zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
  if (( $+functions[compstyle_${zcompstyle}_setup] )); then
    compstyle_${zcompstyle}_setup
  else
    compstyleinit && compstyle ${zcompstyle}
  fi
  unset zcompstyle

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:completion' loaded 'yes'
}

function zephyr_confd {
  #
  # conf.d: Use a Fish-like conf.d directory for sourcing configs.
  #

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  # Find the conf.d directory.
  zstyle -a ':zephyr:plugin:confd' directory '_user_confd'
  typeset -a _confd=(
    ${~_user_confd}
    $__zsh_config_dir/conf.d(N)
    $__zsh_config_dir/zshrc.d(N)
    $__zsh_config_dir/rc.d(N)
    ${ZDOTDIR:-$HOME}/.zshrc.d(N)
  )
  if [[ ! -e "$_confd[1]" ]]; then
    echo >&2 "confd: dir not found '$_confd[1]'."
    return 1
  fi

  # Sort and source conf files.
  typeset -ga _rcs=(${_confd[1]}/*.{z,}sh(N))
  for _rc in ${(o)_rcs}; do
    # ignore files that begin with ~
    [[ ${_rc:t} != '~'* ]] || continue
    source $_rc
  done

  # Clean up.
  unset _rc{,s} {,_user}_confd

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:confd' loaded 'yes'
}

function zephyr_directory {
  #
  # directory: Set options and aliases related to Zsh directories and dirstack.
  #

  # References:
  # - https://github.com/sorin-ionescu/prezto/tree/master/modules/directory
  # - https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/directories.zsh
  # - https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories

  # 16.2.1 Changing Directories
  setopt auto_pushd              # Make cd push the old directory onto the dirstack.
  setopt pushd_minus             # Exchanges meanings of +/- when navigating the dirstack.
  setopt pushd_silent            # Do not print the directory stack after pushd or popd.
  setopt pushd_to_home           # Push to home directory when no argument is given.

  # 16.2.3 Expansion and Globbing
  setopt extended_glob           # Use extended chars (#,~,^) in globbing patterns.
  setopt glob_dots               # Include dotfiles when globbing.

  # 16.2.6 Input/Output
  setopt NO_clobber              # Don't overwrite files with >. Use >| to bypass.
  setopt NO_rm_star_silent       # Ask for confirmation for `rm *' or `rm path/*'

  # 16.2.9 Scripts and Functions
  setopt multios                 # Write to multiple descriptors.

  # Set directory aliases.
  alias -- -='cd -'
  alias dirh='dirs -v'
  () {
    local i dotdots=".."
    for i in {1..9}; do
      alias "$i"="cd -${i}"       # dirstack aliases (eg: "3"="cd -3")
      alias -g "..$i"="$dotdots"  # backref aliases (eg: "..3"="../../..")
      dotdots+='/..'
    done
  }

  ##? up: Quickly go up any number of directories.
  function up {
    local parents=${1:-1}
    if [[ ! "$parents" -gt 0 ]]; then
      echo >&2 "usage: up [<num>]"
      return 1
    fi
    local dotdots=".."
    while (( --parents )); do
      dotdots+="/.."
    done
    cd $dotdots
  }

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:directory' loaded 'yes'
}

function zephyr_editor {
  #
  # editor: Setup Zsh line editor behavior.
  #

  # Return if requirements are not found.
  [[ "$TERM" != 'dumb' ]] || return 1

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  # Treat these characters as part of a word.
  zstyle -s ':zephyr:plugin:editor' wordchars 'WORDCHARS' \
    || WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

  # Use human-friendly identifiers.
  zmodload zsh/terminfo
  typeset -gA key_info
  key_info=(
    'Control'         '\C-'
    'ControlLeft'     '\e[1;5D \e[5D \e\e[D \eOd'
    'ControlRight'    '\e[1;5C \e[5C \e\e[C \eOc'
    'ControlPageUp'   '\e[5;5~'
    'ControlPageDown' '\e[6;5~'
    'Escape'       '\e'
    'Meta'         '\M-'
    'Backspace'    "^?"
    'Delete'       "^[[3~"
    'F1'           "$terminfo[kf1]"
    'F2'           "$terminfo[kf2]"
    'F3'           "$terminfo[kf3]"
    'F4'           "$terminfo[kf4]"
    'F5'           "$terminfo[kf5]"
    'F6'           "$terminfo[kf6]"
    'F7'           "$terminfo[kf7]"
    'F8'           "$terminfo[kf8]"
    'F9'           "$terminfo[kf9]"
    'F10'          "$terminfo[kf10]"
    'F11'          "$terminfo[kf11]"
    'F12'          "$terminfo[kf12]"
    'Insert'       "$terminfo[kich1]"
    'Home'         "$terminfo[khome]"
    'PageUp'       "$terminfo[kpp]"
    'End'          "$terminfo[kend]"
    'PageDown'     "$terminfo[knp]"
    'Up'           "$terminfo[kcuu1]"
    'Left'         "$terminfo[kcub1]"
    'Down'         "$terminfo[kcud1]"
    'Right'        "$terminfo[kcuf1]"
    'BackTab'      "$terminfo[kcbt]"
  )

  # Set empty $key_info values to an invalid UTF-8 sequence to induce silent
  # bindkey failure.
  for key in "${(k)key_info[@]}"; do
    if [[ -z "$key_info[$key]" ]]; then
      key_info[$key]='�'
    fi
  done

  # Allow command line editing in an external editor.
  autoload -Uz edit-command-line
  zle -N edit-command-line

  #
  # Functions
  #

  # Runs bindkey but for all of the keymaps. Running it with no arguments will
  # print out the mappings for all of the keymaps.
  function bindkey-all {
    local keymap=''
    for keymap in $(bindkey -l); do
      [[ "$#" -eq 0 ]] && printf "#### %s\n" "${keymap}" 1>&2
      bindkey -M "${keymap}" "$@"
    done
  }

  # Exposes information about the Zsh Line Editor via the $editor_info associative
  # array.
  function editor-info {
    # Ensure that we're going to set the editor-info for prompts that
    # are managed and/or compatible.
    if zstyle -t ':zephyr:plugin:prompt' managed; then
      # Clean up previous $editor_info.
      unset editor_info
      typeset -gA editor_info

      if [[ "$KEYMAP" == 'vicmd' ]]; then
        zstyle -s ':zephyr:plugin:editor:info:keymap:alternate' format 'REPLY'
        editor_info[keymap]="$REPLY"
      else
        zstyle -s ':zephyr:plugin:editor:info:keymap:primary' format 'REPLY'
        editor_info[keymap]="$REPLY"

        if [[ "$ZLE_STATE" == *overwrite* ]]; then
          zstyle -s ':zephyr:plugin:editor:info:keymap:primary:overwrite' format 'REPLY'
          editor_info[overwrite]="$REPLY"
        else
          zstyle -s ':zephyr:plugin:editor:info:keymap:primary:insert' format 'REPLY'
          editor_info[overwrite]="$REPLY"
        fi
      fi

      unset REPLY
      zle zle-reset-prompt
    fi
  }
  zle -N editor-info

  # Reset the prompt based on the current context and
  # the ps-context option.
  function zle-reset-prompt {
    if zstyle -t ':zephyr:plugin:editor' ps-context; then
      # If we aren't within one of the specified contexts, then we want to reset
      # the prompt with the appropriate editor_info[keymap] if there is one.
      if [[ $CONTEXT != (select|cont) ]]; then
        zle reset-prompt
        zle -R
      fi
    else
      zle reset-prompt
      zle -R
    fi
  }
  zle -N zle-reset-prompt

  # Updates editor information when the keymap changes.
  function zle-keymap-select-default {
    zle editor-info
  }
  hooks-add-hook zle_keymap_select_hook zle-keymap-select-default

  # Enables terminal application mode and updates editor information.
  function zle-line-init-default {
    # The terminal must be in application mode when ZLE is active for $terminfo
    # values to be valid.
    if (( $+terminfo[smkx] )); then
      # Enable terminal application mode.
      echoti smkx
    fi

    # Update editor information.
    zle editor-info
  }
  hooks-add-hook zle_line_init_hook zle-line-init-default

  # Disables terminal application mode and updates editor information.
  function zle-line-finish-default {
    # The terminal must be in application mode when ZLE is active for $terminfo
    # values to be valid.
    if (( $+terminfo[rmkx] )); then
      # Disable terminal application mode.
      echoti rmkx
    fi

    # Update editor information.
    zle editor-info
  }
  hooks-add-hook zle_line_finish_hook zle-line-finish-default

  # Toggles emacs overwrite mode and updates editor information.
  function overwrite-mode {
    zle .overwrite-mode
    zle editor-info
  }
  zle -N overwrite-mode

  # Enters vi insert mode and updates editor information.
  function vi-insert {
    zle .vi-insert
    zle editor-info
  }
  zle -N vi-insert

  # Moves to the first non-blank character then enters vi insert mode and updates
  # editor information.
  function vi-insert-bol {
    zle .vi-insert-bol
    zle editor-info
  }
  zle -N vi-insert-bol

  # Enters vi replace mode and updates editor information.
  function vi-replace  {
    zle .vi-replace
    zle editor-info
  }
  zle -N vi-replace

  # Expands .... to ../..
  function expand-dot-to-parent-directory-path {
    if [[ $LBUFFER = *.. ]]; then
      LBUFFER+='/..'
    else
      LBUFFER+='.'
    fi
  }
  zle -N expand-dot-to-parent-directory-path

  # Displays an indicator when completing.
  function expand-or-complete-with-indicator {
    local indicator
    zstyle -s ':zephyr:plugin:editor:info:completing' format 'indicator'

    # This is included to work around a bug in zsh which shows up when interacting
    # with multi-line prompts.
    if [[ -z "$indicator" ]]; then
      zle expand-or-complete
      return
    fi

    print -Pn "$indicator"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-indicator

  # Inserts 'sudo ' at the beginning of the line.
  function prepend-sudo {
    if [[ "$BUFFER" != su(do|)\ * ]]; then
      BUFFER="sudo $BUFFER"
      (( CURSOR += 5 ))
    fi
  }
  zle -N prepend-sudo

  # Expand aliases
  function glob-alias {
    local -a noexpand_aliases
    zstyle -a ':zephyr:plugin:editor:glob-alias' 'noexpand' 'noexpand_aliases' \
      || noexpand_aliases=()

    # Get last word to the left of the cursor:
    # (A) makes it an array even if there's only one element
    # (z) splits into words using shell parsing
    local word=${${(Az)LBUFFER}[-1]}
    if [[ $noexpand_aliases[(Ie)$word] -eq 0 ]]; then
      zle _expand_alias
      # zle expand-word
    fi
    zle self-insert
  }
  zle -N glob-alias

  # Toggle the comment character at the start of the line. This is meant to work
  # around a buggy implementation of pound-insert in zsh.
  #
  # This is currently only used for the emacs keys because vi-pound-insert has
  # been reported to work properly.
  function pound-toggle {
    if [[ "$BUFFER" = '#'* ]]; then
      # Because of an oddity in how zsh handles the cursor when the buffer size
      # changes, we need to make this check before we modify the buffer and let
      # zsh handle moving the cursor back if it's past the end of the line.
      if [[ $CURSOR != $#BUFFER ]]; then
        (( CURSOR -= 1 ))
      fi
      BUFFER="${BUFFER:1}"
    else
      BUFFER="#$BUFFER"
      (( CURSOR += 1 ))
    fi
  }
  zle -N pound-toggle

  # Reset to default key bindings.
  bindkey -d

  #
  # Emacs Key Bindings
  #

  for key in "$key_info[Escape]"{B,b} "${(s: :)key_info[ControlLeft]}" \
    "${key_info[Escape]}${key_info[Left]}"
    bindkey -M emacs "$key" emacs-backward-word
  for key in "$key_info[Escape]"{F,f} "${(s: :)key_info[ControlRight]}" \
    "${key_info[Escape]}${key_info[Right]}"
    bindkey -M emacs "$key" emacs-forward-word

  # Kill to the beginning of the line.
  for key in "$key_info[Escape]"{K,k}
    bindkey -M emacs "$key" backward-kill-line

  # Redo.
  bindkey -M emacs "$key_info[Escape]_" redo

  # Search previous character.
  bindkey -M emacs "$key_info[Control]X$key_info[Control]B" vi-find-prev-char

  # Match bracket.
  bindkey -M emacs "$key_info[Control]X$key_info[Control]]" vi-match-bracket

  # Edit command in an external editor.
  bindkey -M emacs "$key_info[Control]X$key_info[Control]E" edit-command-line

  if (( $+widgets[history-incremental-pattern-search-backward] )); then
    bindkey -M emacs "$key_info[Control]R" \
      history-incremental-pattern-search-backward
    bindkey -M emacs "$key_info[Control]S" \
      history-incremental-pattern-search-forward
  fi

  # Toggle comment at the start of the line. Note that we use pound-toggle which
  # is similar to pount insert, but meant to work around some issues that were
  # being seen in iTerm.
  bindkey -M emacs "$key_info[Escape];" pound-toggle

  #
  # Vi Key Bindings
  #

  # Edit command in an external editor emacs style (v is used for visual mode)
  bindkey -M vicmd "$key_info[Control]X$key_info[Control]E" edit-command-line

  # Undo/Redo
  bindkey -M vicmd "u" undo
  bindkey -M viins "$key_info[Control]_" undo
  bindkey -M vicmd "$key_info[Control]R" redo

  if (( $+widgets[history-incremental-pattern-search-backward] )); then
    bindkey -M vicmd "?" history-incremental-pattern-search-backward
    bindkey -M vicmd "/" history-incremental-pattern-search-forward
  else
    bindkey -M vicmd "?" history-incremental-search-backward
    bindkey -M vicmd "/" history-incremental-search-forward
  fi

  # Toggle comment at the start of the line.
  bindkey -M vicmd "#" vi-pound-insert

  #
  # Emacs and Vi Key Bindings
  #

  # Unbound keys in vicmd and viins mode will cause really odd things to happen
  # such as the casing of all the characters you have typed changing or other
  # undefined things. In emacs mode they just insert a tilde, but bind these keys
  # in the main keymap to a noop op so if there is no keybind in the users mode
  # it will fall back and do nothing.
  function _editor-zle-noop {  ; }
  zle -N _editor-zle-noop
  local -a unbound_keys
  unbound_keys=(
    "${key_info[F1]}"
    "${key_info[F2]}"
    "${key_info[F3]}"
    "${key_info[F4]}"
    "${key_info[F5]}"
    "${key_info[F6]}"
    "${key_info[F7]}"
    "${key_info[F8]}"
    "${key_info[F9]}"
    "${key_info[F10]}"
    "${key_info[F11]}"
    "${key_info[F12]}"
    "${key_info[PageUp]}"
    "${key_info[PageDown]}"
    "${key_info[ControlPageUp]}"
    "${key_info[ControlPageDown]}"
  )
  for keymap in $unbound_keys; do
    bindkey -M viins "${keymap}" _editor-zle-noop
    bindkey -M vicmd "${keymap}" _editor-zle-noop
  done

  # Keybinds for all keymaps
  for keymap in 'emacs' 'viins' 'vicmd'; do
    bindkey -M "$keymap" "$key_info[Home]" beginning-of-line
    bindkey -M "$keymap" "$key_info[End]" end-of-line
  done

  # Keybinds for all vi keymaps
  for keymap in viins vicmd; do
    # Ctrl + Left and Ctrl + Right bindings to forward/backward word
    for key in "${(s: :)key_info[ControlLeft]}"
      bindkey -M "$keymap" "$key" vi-backward-word
    for key in "${(s: :)key_info[ControlRight]}"
      bindkey -M "$keymap" "$key" vi-forward-word
  done

  # Keybinds for emacs and vi insert mode
  for keymap in 'emacs' 'viins'; do
    bindkey -M "$keymap" "$key_info[Insert]" overwrite-mode
    bindkey -M "$keymap" "$key_info[Delete]" delete-char
    bindkey -M "$keymap" "$key_info[Backspace]" backward-delete-char

    bindkey -M "$keymap" "$key_info[Left]" backward-char
    bindkey -M "$keymap" "$key_info[Right]" forward-char

    # Expand history on space.
    bindkey -M "$keymap" ' ' magic-space

    # Clear screen.
    bindkey -M "$keymap" "$key_info[Control]L" clear-screen

    # Expand command name to full path.
    for key in "$key_info[Escape]"{E,e}
      bindkey -M "$keymap" "$key" expand-cmd-path

    # Duplicate the previous word.
    for key in "$key_info[Escape]"{M,m}
      bindkey -M "$keymap" "$key" copy-prev-shell-word

    # Use a more flexible push-line.
    for key in "$key_info[Control]Q" "$key_info[Escape]"{q,Q}
      bindkey -M "$keymap" "$key" push-line-or-edit

    # Bind Shift + Tab to go to the previous menu item.
    bindkey -M "$keymap" "$key_info[BackTab]" reverse-menu-complete

    # Complete in the middle of word.
    bindkey -M "$keymap" "$key_info[Control]I" expand-or-complete

    # Expand .... to ../..
    if zstyle -t ':zephyr:plugin:editor' dot-expansion; then
      bindkey -M "$keymap" "." expand-dot-to-parent-directory-path
    fi

    # Display an indicator when completing.
    bindkey -M "$keymap" "$key_info[Control]I" \
      expand-or-complete-with-indicator

    # Insert 'sudo ' at the beginning of the line.
    bindkey -M "$keymap" "$key_info[Control]X$key_info[Control]S" prepend-sudo
  done

  # Delete key deletes character in vimcmd cmd mode instead of weird default functionality
  bindkey -M vicmd "$key_info[Delete]" delete-char

  # Do not expand .... to ../.. during incremental search.
  if zstyle -t ':zephyr:plugin:editor' dot-expansion; then
    bindkey -M isearch . self-insert 2> /dev/null
  fi

  # Expand aliases
  if zstyle -t ':zephyr:plugin:editor' glob-alias; then
    # space expands all aliases, including global
    bindkey -M emacs " " glob-alias
    bindkey -M viins " " glob-alias

    # control-space to make a normal space
    bindkey -M emacs "^ " magic-space
    bindkey -M viins "^ " magic-space

    # normal space during searches
    bindkey -M isearch " " magic-space
  fi

  #
  # Layout
  #

  # Set the key layout.
  zstyle -s ':zephyr:plugin:editor' key-bindings 'key_bindings'
  if [[ "$key_bindings" == (emacs|) ]]; then
    bindkey -e
  elif [[ "$key_bindings" == vi ]]; then
    bindkey -v
  else
    print "editor: invalid key bindings: $key_bindings" >&2
  fi

  unset key{,map,_bindings}

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:editor' loaded 'yes'
}

function zephyr_environment {
  #
  # environment: Ensure common environment variables are set.
  #

  # References:
  # - https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh
  # - https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zprofile

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  # 16.2.3 Expansion and Globbing
  setopt extended_glob           # Use extended chars (#,~,^) in globbing patterns.

  # 16.2.6 Input/Output
  setopt interactive_comments    # Enable comments in interactive shell.
  setopt rc_quotes               # Allow 'Hitchhikers''s Guide' instead of 'Hitchhikers'\''s Guide'.
  setopt NO_flow_control         # Disable start/stop characters (usually ^Q/^S) in shell editor.
  setopt NO_mail_warning         # Don't print a warning message if a mail file has been accessed.

  # 16.2.7 Job Control
  setopt auto_resume             # Attempt to resume existing job before creating a new process.
  setopt long_list_jobs          # List jobs in the long format by default.
  setopt notify                  # Report status of background jobs immediately.
  setopt NO_bg_nice              # Don't run all background jobs at a lower priority.
  setopt NO_check_jobs           # Don't report on jobs when shell exit.
  setopt NO_hup                  # Don't kill jobs on shell exit.

  # 16.2.12 Zle
  setopt combining_chars         # Combine 0-len chars with the base character (eg: accents).
  setopt NO_beep                 # Do not beep on error in line editor.

  # Allow mapping Ctrl+S and Ctrl+Q shortcuts
  [[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

  # Set XDG base dirs.
  # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
  if zstyle -T ':zephyr:plugin:environment' use-xdg-basedirs; then
    export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
    export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
    export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
    () {
      local _zdir; for _zdir in $@; [ -d ${(P)_zdir} ] || mkdir -p ${(P)_zdir}
    } XDG_{CONFIG,CACHE,DATA,STATE}_HOME
  fi

  # Editors
  export EDITOR=${EDITOR:-nano}
  export VISUAL=${VISUAL:-nano}
  export PAGER=${PAGER:-less}

  # Set browser.
  if [[ "$OSTYPE" == darwin* ]]; then
    export BROWSER=${BROWSER:-open}
  fi

  # Set language.
  export LANG=${LANG:-en_US.UTF-8}

  # Ensure path arrays do not contain duplicates.
  typeset -gU cdpath fpath mailpath path

  # Set the list of directories that Zsh searches for programs.
  if [[ ! -v prepath ]]; then
    # If path ever gets out of order, you can use `path=($prepath $path)` to reset it.
    typeset -ga prepath=(
      $HOME/{,s}bin(N)
      $HOME/.local/{,s}bin(N)
    )
  fi
  path=(
    $prepath
    /opt/{homebrew,local}/{,s}bin(N)
    /usr/local/{,s}bin(N)
    $path
  )

  # Set the default Less options.
  # Mouse-wheel scrolling can be disabled with -X (disable screen clearing).
  # Add -X to disable it.
  if [[ -z "$LESS" ]]; then
    export LESS='-g -i -M -R -S -w -z-4'
  fi

  # Set the Less input preprocessor.
  # Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
  if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
  fi

  # Reduce key delay
  export KEYTIMEOUT=${KEYTIMEOUT:-1}

  # Make Apple Terminal behave.
  if [[ "$OSTYPE" == darwin* ]]; then
    export SHELL_SESSIONS_DISABLE=${SHELL_SESSIONS_DISABLE:-1}
  fi

  # Use `< file` to quickly view the contents of any file.
  [[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:environment' loaded 'yes'
}

function zephyr_helper {
  #
  # helper: Common variables and functions used by Zephyr plugins.
  #

  ##? Checks if a file can be autoloaded by trying to load it in a subshell.
  function is-autoloadable {
    ( unfunction "$1"; autoload -U +X "$1" ) &> /dev/null
  }

  ##? Checks if a name is a command, function, or alias.
  function is-callable {
    (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
  }

  ##? Check whether a string represents "true" (1, y, yes, t, true, o, on).
  function is-true {
    [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|o(n|)) ]]
  }

  # OS checks.
  function is-macos  { [[ "$OSTYPE" == darwin* ]] }
  function is-linux  { [[ "$OSTYPE" == linux*  ]] }
  function is-bsd    { [[ "$OSTYPE" == *bsd*   ]] }
  function is-cygwin { [[ "$OSTYPE" == cygwin* ]] }
  function is-termux { [[ "$OSTYPE" == linux-android ]] }

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:helper' loaded 'yes'
}

function zephyr_history {
  #
  # history: Set history options and define history aliases.
  #

  # References:
  # - https://github.com/sorin-ionescu/prezto/tree/master/modules/history
  # - https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
  # - https://zsh.sourceforge.io/Doc/Release/Options.html#History

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  # 16.2.4 History
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
  if zstyle -T ':zephyr:plugin:history' use-xdg-basedirs; then
    _zhistfile=${__zsh_user_data_dir}/zsh_history
  else
    _zhistfile=${ZDOTDIR:-$HOME}/.zsh_history
  fi

  # Set the history file to whereever the user specified, or the default
  zstyle -s ':zephyr:plugin:history' histfile 'HISTFILE' \
    || HISTFILE="$_zhistfile"

  # Make sure the user didn't store an empty history file, or a literal '~',
  # and that the history path exists. Basically, save the user from themselves.
  [[ -z "$HISTFILE" ]] && HISTFILE=$_zhistfile || HISTFILE=${~HISTFILE}
  [[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
  unset _zhistfile

  # Set history file size (Zsh default 1000, Zephyr multiply by 100).
  zstyle -s ':zephyr:plugin:history' savehist 'SAVEHIST' \
    || SAVEHIST=100000

  # Set session history size (Zsh default 2000, Zephyr multiply by 10).
  zstyle -s ':zephyr:plugin:history' histsize 'HISTSIZE' \
    || HISTSIZE=20000

  # Set Zsh aliases related to history.
  alias hist='fc -li'
  alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -nr | head"

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:history' loaded 'yes'
}

function zephyr_homebrew {
  #
  # homebrew: Environment variables and functions for homebrew users.
  #

  # References:
  # - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew
  # - https://github.com/sorin-ionescu/prezto/tree/master/modules/homebrew

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  # Where is brew?
  # Setup homebrew if it exists on the system.
  typeset -aU _brewcmd=(
    $commands[brew]
    $HOME/.homebrew/bin/brew(N)
    $HOME/.linuxbrew/bin/brew(N)
    /opt/homebrew/bin/brew(N)
    /usr/local/bin/brew(N)
    /home/linuxbrew/.linuxbrew/bin/brew(N)
  )
  (( ${#_brewcmd} )) || return 1

  # brew shellenv
  if zstyle -t ':zephyr:plugin:homebrew' 'use-cache'; then
    cached-eval 'brew_shellenv' $_brewcmd[1] shellenv
  else
    source <($_brewcmd[1] shellenv)
  fi
  unset _brewcmd

  # Ensure user bins preceed homebrew in path.
  path=($prepath $path)

  # Default to no tracking.
  HOMEBREW_NO_ANALYTICS=${HOMEBREW_NO_ANALYTICS:-1}

  # Add brewed Zsh to fpath
  if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
    fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
  fi

  # Set aliases.
  alias brewup="brew update && brew upgrade && brew cleanup"
  alias brewinfo="brew leaves | xargs brew desc --eval-all"

  ##? Show brewed apps.
  function brews {
    local formulae="$(brew leaves | xargs brew deps --installed --for-each)"
    local casks="$(brew list --cask 2>/dev/null)"

    local blue="$(tput setaf 4)"
    local bold="$(tput bold)"
    local off="$(tput sgr0)"

    echo "${blue}==>${off} ${bold}Formulae${off}"
    echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
    echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
  }

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:homebrew' loaded 'yes'
}

function zephyr_macos {
  function _manp {
    #compdef manp
    #autoload

    # completions for manp match man
    _man
  }

  function cdf {
    #!/bin/zsh
    ##? cdf - Change to the current Finder directory.
    cd "$(pfd)"
  }

  function flushdns {
    #!/bin/zsh
    ##? flushdns - Flush the DNS cache.
    dscacheutil -flushcache && sudo killall -HUP mDNSResponder
  }

  function hidefiles {
    #!/bin/zsh
    ##? hidefiles - Hide hidden dotfiles in Finder.
    defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder
  }

  function lmk {
    #!/bin/zsh
    ##? lmk - Have Siri let me know when a process is complete.
    ##?
    ##? Example:
    ##?   sleep 2 && lmk
    if (( $# )); then
      say "$@"
    else
      say 'Process complete.'
    fi
  }

  function mand {
    #!/bin/zsh
    ##? mand - Read man page with Dash.app.
    local -a o_docset=(manpages)
    zmodload zsh/zutil
    zparseopts -D -F -K -- \
      {d,-docset}:=o_docset ||
      return 1

    dashcmd="dash://${o_docset[-1]}%3A$1"
    open -a Dash.app $dashcmd 2> /dev/null
    if test $? -ne 0; then
      echo >&2 "$0: Dash is not installed"
      return 2
    fi
  }

  function manp {
    #!/bin/zsh
    ##? manp - read man page with Preview.app
    # https://scriptingosx.com/2022/11/on-viewing-man-pages-ventura-update/
    if ! (( $# )); then
      echo >&2 'manp: You must specify the manual page you want'
      return 1
    fi
    mandoc -T pdf "$(/usr/bin/man -w $@)" | open -fa Preview
  }

  function ofd {
    #!/bin/zsh
    ##? ofd - Open the current directory in Finder
    open "$PWD"
  }

  function peek {
    #!/bin/zsh
    ##? peek - Take a quick look at a file using an appropriate viewer
    (( $# > 0 )) && qlmanage -p $* &>/dev/null &
  }

  function pfd {
    #!/bin/zsh
    ##? pfd - Print the frontmost Finder directory.
    #function pfd {
    osascript 2> /dev/null <<EOF
      tell application "Finder"
        return POSIX path of (target of first window as text)
      end tell
EOF
    #}
  }

  function pfs {
    #!/bin/zsh
    ##? pfs - Print the current Finder selection
    #function pfs {
    osascript 2>&1 <<EOF
      tell application "Finder" to set the_selection to selection
      if the_selection is not {}
        repeat with an_item in the_selection
          log POSIX path of (an_item as text)
        end repeat
      end if
EOF
    #}
  }

  function pushdf {
    #!/bin/zsh
    # pushdf - Push the current Finder directory to the dirstack.
    pushd "$(pfd)"
  }

  function rmdsstore {
    #!/bin/zsh
    ##? rmdsstore - Remove .DS_Store files recursively in a directory.
    find "${@:-.}" -type f -name .DS_Store -delete
  }

  function showfiles {
    #!/bin/zsh
    ##? showfiles - Show hidden dotfiles in Finder.
    defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
  }

  function trash {
    #!/bin/zsh
    ##? trash - Move files to macOS trash

    #function trash {

    emulate -L zsh
    setopt local_options extended_glob

    if (( $# == 0 )); then
      echo >&2 "Usage: trash <files>"
      return 1
    fi

    if [[ $OSTYPE != darwin* ]]; then
      print -ru2 -- "trash: macOS not detected."
      return 1
    fi

    local file
    local -a files
    for file in $@; do
      if [[ -e $file ]]; then
        files+=("the POSIX file \"${file:A}\"")
      else
        print -ru2 -- "trash: No such file or directory '$file'."
        return 1
      fi
    done

    if (( $#files == 0 )); then
      print -ru2 -- 'usage: trash <files...>'
      return 64 # match rm's return code
    fi

    osascript 2>&1 >/dev/null -e "tell app \"Finder\" to move { "${(pj., .)files}" } to trash"

    #}
  }

  #
  # macos: Aliases and functions for macOS users.
  #

  # References
  # - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
  # - https://github.com/sorin-ionescu/prezto/tree/master/modules/osx

  # Expecting macOS.
  [[ "$OSTYPE" == darwin* ]] || return 1

  # Load plugin functions.
  0=${(%):-%N}
  fpath=(${0:a:h}/functions $fpath)
  autoload -Uz ${0:a:h}/functions/*(.:t)

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:macos' loaded 'yes'
}

function zephyr_prompt {
  function prompt_starship_setup {
    #!/bin/zsh
    #function prompt_starship_setup {
      0=${(%):-%x}

      if ! (( $+commands[starship] )); then
        # We could install, but running a remotely hosted shell script is not a risk
        # Zephyr should assume. Let's let the user decide whether to install it.
        echo >&2 "Starship prompt not installed. See https://starship.rs to install."
        return 1
      fi

      # When loaded through the prompt command, these prompt_* options will be enabled
      prompt_opts=(cr percent sp subst)

      # Set the starship config based on the argument if provided.
      local prompt_config="$1"
      if [[ -n "$prompt_config" ]]; then
        local -a configs=(
          ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/themes/${prompt_config}.toml(N)
          ${XDG_CONFIG_HOME:-$HOME/.config}/starship/${prompt_config}.toml(N)
          ${0:a:h:h}/themes/${prompt_config}.toml(N)
        )
        if (( $#configs )); then
          export STARSHIP_CONFIG=$configs[1]
        else
          unset STARSHIP_CONFIG
        fi
      fi

      local starship_init=${XDG_CACHE_HOME:-~/.cache}/zephyr/starship_init.zsh
      [[ -d $starship_init:h ]] || mkdir -p $starship_init:h

      local cache=($starship_init(Nmh-20))
      (( $#cache )) || starship init zsh --print-full-init >| $starship_init
      source $starship_init
    #}
  }

  function prompt_zephyr_setup {
    #!/bin/zsh
    prompt_starship_setup zephyr
  }

  #
  # prompt: Set zsh prompt.
  #

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  #
  # Options
  #

  # 16.2.8 Prompting
  setopt prompt_subst    # Expand parameters in prompt variables.

  #
  # Variables
  #

  # Set 2 space indent for each new level in a multi-line script
  # This can then be overridden by a prompt, but is a better default than zsh's
  PS2='${${${(%):-%_}//[^ ]}// /  }    '

  #
  # Functions
  #

  # Add Zephyr's prompt functions to fpath.
  fpath=(${0:a:h}/functions $fpath)

  # if zstyle -t ':zephyr:plugin:prompt:starship' transient; then
  #   setopt transient_rprompt
  #   source ${0:a:h}/starship_transient_prompt.zsh
  #   zle -N zle-line-init
  # fi

  function promptinit {
    # Initialize real built-in prompt system.
    unfunction promptinit prompt &>/dev/null
    autoload -Uz promptinit && promptinit "$@"

    # If we're here, it's because the user manually ran promptinit, which means we
    # no longer need the failsafe hook.
    hooks-add-hook -d post_zshrc run-promptinit-post-zshrc
  }

  # Wrap promptinit.
  function run-promptinit {
    # Initialize real built-in prompt system.
    unfunction promptinit prompt &>/dev/null
    autoload -Uz promptinit && promptinit

    # Set the prompt if specified
    local -a prompt_theme
    zstyle -a ':zephyr:plugin:prompt' theme 'prompt_argv'

    if zstyle -t ":zephyr:plugin:prompt:${prompt_argv[1]}" transient; then
      setopt transient_rprompt  # Remove right prompt artifacts from prior commands.
    fi

    if [[ $TERM == (dumb|linux|*bsd*) ]]; then
      prompt 'off'
    elif (( $#prompt_argv > 0 )); then
      prompt "$prompt_argv[@]"
    fi
    unset prompt_argv

    # Keep prompt array sorted.
    prompt_themes=( "${(@on)prompt_themes}" )
  }

  # Failsafe to make sure promptinit runs during the post_zshrc event
  function run-promptinit-post-zshrc {
    run-promptinit
    hooks-add-hook -d post_zshrc run-promptinit-post-zshrc
  }
  hooks-add-hook post_zshrc run-promptinit-post-zshrc

  # Mark this plugin as loaded.
  zstyle ":zephyr:plugin:prompt" loaded 'yes'
}

function zephyr_utility {
  #
  # utility: Misc Zsh shell options, utilities, and attempt at cross-platform conformity.
  #

  # References:
  # - https://github.com/sorin-ionescu/prezto/blob/master/modules/utility/init.zsh
  # - https://github.com/belak/zsh-utils/blob/main/utility/utility.plugin.zsh

  # Use built-in paste magic.
  autoload -Uz bracketed-paste-url-magic
  zle -N bracketed-paste bracketed-paste-url-magic
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic

  # Load more specific 'run-help' function from $fpath.
  (( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
  alias help=run-help

  # Make ls more useful.
  if (( ! $+commands[dircolors] )) && [[ "$OSTYPE" != darwin* ]]; then
    # Group dirs first on non-BSD systems
    alias ls="${aliases[ls]:-ls} --group-directories-first"
  fi
  # Show human readable file sizes.
  alias ls="${aliases[ls]:-ls} -h"

  # Ensure python commands exist.
  if (( $+commands[python3] )) && ! (( $+commands[python] )); then
    alias python=python3
  fi
  if (( $+commands[pip3] )) && ! (( $+commands[pip] )); then
    alias pip=pip3
  fi

  # Ensure envsubst command exists.
  if ! (( $+commands[envsubst] )); then
    alias envsubst="python -c 'import os,sys;[sys.stdout.write(os.path.expandvars(l)) for l in sys.stdin]'"
  fi

  # Ensure hd (hex dump) command exists.
  if ! (( $+commands[hd] )) && (( $+commands[hexdump] )); then
    alias hd="hexdump -C"
  fi

  # Ensure open command exists.
  if ! (( $+commands[open] )); then
    if [[ "$OSTYPE" == cygwin* ]]; then
      alias open='cygstart'
    elif [[ "$OSTYPE" == linux-android ]]; then
      alias open='termux-open'
    elif (( $+commands[xdg-open] )); then
      alias open='xdg-open'
    fi
  fi

  # Ensure pbcopy/pbpaste commands exist.
  if ! (( $+commands[pbcopy] )); then
    if [[ "$OSTYPE" == cygwin* ]]; then
      alias pbcopy='tee > /dev/clipboard'
      alias pbpaste='cat /dev/clipboard'
    elif [[ "$OSTYPE" == linux-android ]]; then
      alias pbcopy='termux-clipboard-set'
      alias pbpaste='termux-clipboard-get'
    elif (( $+commands[wl-copy] && $+commands[wl-paste] )); then
      alias pbcopy='wl-copy'
      alias pbpaste='wl-paste'
    elif [[ -n $DISPLAY ]]; then
      if (( $+commands[xclip] )); then
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
      elif (( $+commands[xsel] )); then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
      fi
    fi
  fi

  ##? Cross platform `sed -i` syntax
  function sedi {
    # GNU/BSD
    sed --version &>/dev/null && sed -i -- "$@" || sed -i "" "$@"
  }

  # Mark this plugin as loaded.
  zstyle ':zephyr:plugin:utility' loaded 'yes'
}

function zephyr_zfunctions {
  #
  # zfunctions: Autoload all function files from your $ZDOTDIR/functions directory.
  #

  # Bootstrap.
  0=${(%):-%N}
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

  ##? autoload-dir - Autoload function files in directory
  function autoload-dir {
    local zdir
    local -a zautoloads
    for zdir in $@; do
      [[ -d "$zdir" ]] || continue
      fpath=("$zdir" $fpath)
      zautoloads=($zdir/*~_*(N.:t))
      (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
    done
  }

  ##? funcsave - Save a function
  function funcsave {
    emulate -L zsh; setopt local_options
    : ${ZFUNCDIR:=$__zsh_config_dir/functions}

    # check args
    if (( $# == 0 )); then
      echo >&2 "funcsave: Expected at least 1 args, got only 0."
      return 1
    elif ! typeset -f "$1" > /dev/null; then
      echo >&2 "funcsave: Unknown function '$1'."
      return 1
    elif [[ ! -d "$ZFUNCDIR" ]]; then
      echo >&2 "funcsave: Directory not found '$ZFUNCDIR'."
      return 1
    fi

    # make sure the function is loaded in case it's already lazy
    autoload +X "$1" > /dev/null

    # remove first/last lines (ie: 'function foo {' and '}') and de-indent one level
    type -f "$1" | awk 'NR>2 {print prev} {gsub(/^\t/, "", $0); prev=$0}' >| "$ZFUNCDIR/$1"
  }

  ##? funced - edit the function specified
  function funced {
    emulate -L zsh; setopt local_options
    : ${ZFUNCDIR:=$__zsh_config_dir/functions}

    # check args
    if (( $# == 0 )); then
      echo >&2 "funced: Expected at least 1 args, got only 0."
      return 1
    elif [[ ! -d "$ZFUNCDIR" ]]; then
      echo >&2 "funced: Directory not found '$ZFUNCDIR'."
      return 1
    fi

    # new function definition: make a file template
    if [[ ! -f "$ZFUNCDIR/$1" ]]; then
      local -a funcstub
      funcstub=(
        "#\!/bin/zsh"
        "#function $1 {"
        ""
        "#}"
        "#$1 \"\$@\""
      )
      printf '%s\n' "${funcstub[@]}" > "$ZFUNCDIR/$1"
      autoload -Uz "$ZFUNCDIR/$1"
    fi

    # open the function file
    if [[ -n "$VISUAL" ]]; then
      $VISUAL "$ZFUNCDIR/$1"
    else
      ${EDITOR:-vim} "$ZFUNCDIR/$1"
    fi
  }

  ##? funcfresh - Reload an autoload function
  function funcfresh {
    if (( $# == 0 )); then
      echo >&2 "funcfresh: Expecting function argument."
      return 1
    elif ! (( $+functions[$1] )); then
      echo >&2 "funcfresh: Function not found '$1'."
      return 1
    fi
    unfunction $1
    autoload -Uz $1
  }

  # Set ZFUNCDIR.
  if [[ -z "$ZFUNCDIR" ]]; then
    zstyle -s ':zephyr:plugin:zfunctions' directory 'ZFUNCDIR' || ZFUNCDIR=$__zsh_config_dir/functions
  fi

  # Autoload ZFUNCDIR.
  if [[ -d "$ZFUNCDIR" ]]; then
    autoload-dir $ZFUNCDIR(N/) $ZFUNCDIR/*(N/)
  fi

  # Mark this plugin as loaded.
  zstyle ":zephyr:plugin:zfunctions" loaded 'yes'
}

