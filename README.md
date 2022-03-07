# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where
Zephyr comes in. Set up completions, keybindings, history, and much more.

## Installation

Add the following snippet to your `.zshrc`:

```zsh
# clone zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone https://github.com/zshzoo/zephyr ${ZDOTDIR:-~}/.zephyr

# source zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh

# choose your prompt
prompt starship
```

## Prompts

Zephyr supports the Zsh built-in prompt command, and including the prompt plugin will
run [promptinit]. Zephyr comes with the [starship] prompt.

To change your prompt, you simply call `prompt $theme` after sourcing Zephyr in your
`.zshrc`.

For example:

```zsh
# .zshrc
prompt starship
```

## Customizing

You can customize which plugins are loaded by adding the following to your `.zshrc`:

```zsh
zephyr_plugins=(
  environment
  terminal
  editor
  history
  directory
  utility
  prompt
  zfunctions
  confd
  completions
)
zstyle ':zephyr:load' plugins $zephyr_plugins
```

## Credits

Zephyr is a derivative work of the following great projects:

- [Oh-My-Zsh][ohmyzsh]
- [Prezto][prezto]
- [zsh-utils][zsh-utils]
- [fish][fish]


[fish]:                          https://fishshell.com
[ohmyzsh]:                       https://github.com/ohmyzsh/ohmyzsh
[prezto]:                        https://github.com/sorin-ionescu/prezto
[promptinit]:                    https://github.com/zsh-users/zsh/blob/master/Functions/Prompts/promptinit
[starship]:                      https://starship.rs
[zsh-utils]:                     https://github.com/belak/zsh-utils
