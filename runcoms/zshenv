###
# .zshenv Define environment variables.
###

# Set ZDOTDIR to move your Zsh config out of $HOME.
# ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
