###
# utility - Common shell utilities, many aimed at making cross platform work less painful.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%x}
: ${ZEPHYR_HOME:=${0:A:h:h:h}}
zstyle -t ':zephyr:core' initialized || . $ZEPHYR_HOME/lib/init.zsh

#
# Init
#

# Use zsh-utils utility.
source $ZEPHYR_HOME/.external/zsh-utils/utility/utility.plugin.zsh

# Use zsh-bench.
export PATH="$ZEPHYR_HOME/.external/zsh-bench:$PATH"

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

#
# Aliases
#

[[ -n "$GREP_EXCLUSIONS" ]] || typeset -a GREP_EXCLUSIONS=(.bzr CVS .git .hg .svn .idea .tox .vscode)
alias grep="${aliases[grep]:-grep} --exclude-dir={${(j:,:)GREP_EXCLUSIONS}}"
