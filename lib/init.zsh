###
# Zephyr initialization.
###

0=${(%):-%x}
ZEPHYR_HOME="${ZEPHYR_HOME:-$0:A:h:h}"

# Load zephyr functions
fpath+="$ZEPHYR_HOME/functions"
autoload -Uz autoload-dir
autoload-dir "$ZEPHYR_HOME/functions"

zstyle ':zephyr:core' initialized 'yes'

# # clone zephyr external plugins
# zephyr-clone \
#   zdharma-continuum/fast-syntax-highlighting \
#   romkatv/zsh-bench \
#   zsh-users/zsh-autosuggestions \
#   zsh-users/zsh-completions \
#   zsh-users/zsh-history-substring-search \
#   zsh-users/zsh-syntax-highlighting
