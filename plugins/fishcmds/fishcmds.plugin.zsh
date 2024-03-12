#
# fishcmds: Commands to make Fish users feel more at home in Zsh.
#

# Load plugin functions.
0=${(%):-%N}
fpath=(${0:a:h}/functions $fpath)
autoload -Uz ${0:a:h}/functions/*(.:t)

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:fishcmds' loaded 'yes'
