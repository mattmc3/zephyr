#
# Init
#

0=${(%):-%x}
fpath+=${0:A:h}/functions
autoload -Uz ${0:A:h}/functions/man
autoload -Uz ${0:A:h}/functions/showcolors
