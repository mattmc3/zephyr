0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h:h}}
(( $+functions[autoload-dir] )) || autoload -Uz $ZEPHYR_HOME/functions/autoload-dir
autoload-dir $ZEPHYR_HOME/functions
[[ -d $ZEPHYR_HOME/.external ]] || zephyr clonedeps
zstyle ':zephyr:core' initialized yes
