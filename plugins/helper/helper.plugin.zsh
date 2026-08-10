#region HEADER
#
# helper: Deprecated. The shared functions moved to lib/bootstrap.zsh and
# functions/. This remains so that bundling `path:plugins/helper` keeps working.
#

0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
#endregion

#region MARK LOADED
zstyle ':zephyr:plugin:helper' loaded 'yes'
#endregion
