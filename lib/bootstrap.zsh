#region HEADER
#
# bootstrap: Ensure Zephyr is properly boostrapped.
#

# Set ZEPHYR_HOME.
0=${(%):-%N}
: ${ZEPHYR_HOME:=${0:a:h:h}}
#endregion

# Set critical Zsh options. They live here rather than in zephyr-bootstrap so that
# function can emulate -L zsh without these going out of scope with it.
setopt extended_glob interactive_comments

# Finding ZEPHYR_HOME is all this file really does. The work lives in functions/, and
# this stays a file to source so a plugin loaded on its own has one line to call.
#
# Wrapped in an anonymous function for the emulate: a caller who already set
# ksh_arrays would otherwise collapse $fpath to its first element here, and Zsh's own
# function directories would go with it.
() {
  emulate -L zsh
  fpath=($ZEPHYR_HOME/functions $fpath)
  autoload -Uz zephyr-bootstrap cached-eval gen-uuid7 mkcd mktmpcd
  zephyr-bootstrap
}
