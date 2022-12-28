echo >&2 "WARNING: Zephyr 'completions' plugin renamed to 'completion'."
echo >&2 "!!!!!!!: This plugin provided with the legacy name is for compatibility only."
echo >&2 "!!!!!!!: Please update your .zshrc with the new name."
echo >&2 "!!!!!!!: This deprecated plugin will be removed February 2023."
source ${0:a:h:h}/completion/completion.plugin.zsh
