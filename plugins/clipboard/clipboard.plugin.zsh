#
# clipboard - clipboard utilities
#

#
# References
#

# https://github.com/neovim/neovim/blob/e682d799fa3cf2e80a02d00c6ea874599d58f0e7/runtime/autoload/provider/clipboard.vim#L55-L121
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/clipboard.zsh
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copybuffer
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copyfile
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%N}

#
# External
#

source ${0:A:h}/external/omz_clipboard.zsh
source ${0:A:h}/external/omz_copybuffer.plugin.zsh
source ${0:A:h}/external/omz_copyfile.plugin.zsh
source ${0:A:h}/external/omz_copypath.plugin.zsh

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:clipboard" loaded 'yes'
