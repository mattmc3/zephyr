#region HEADER
#
# fishify: Add Fish commands to Zsh
#
#endregion

# Return if requirements are not met.
! zstyle -t ":zephyr:plugin:fishify" skip || return 0

# Load plugin functions.
0=${(%):-%N}
fpath=(${0:a:h}/functions $fpath)
autoload -Uz ${0:a:h}/functions/*(.:t)

#region MARK LOADED
zstyle ':zephyr:plugin:fishify' loaded 'yes'
#endregion
