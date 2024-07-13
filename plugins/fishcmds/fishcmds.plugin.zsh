#
# fishcmds: Commands to make Fish users feel more at home in Zsh.
#

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

# Add fish-like commands
path=(${0:a:h}/bin $path)
