# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where Zephyr comes in. Zephyr uses built-in Zsh features to set up better default options, completions, keybindings, history, and much more.

Zephyr can be thought of as a fast, lightweight alternative to big bloated Zsh frameworks like Oh-My-Zsh and Prezto. Combine Zephyr with a [plugin manager][antidote] and you'll have a powerful Zsh setup that rivals anything out there.

## Install

### Using a Plugin manager

Using [antidote]:

```shell
antidote install mattmc3/zephyr
```

### Manually

Add the following snippet to your `.zshrc`:

```zsh
# clone zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone https://github.com/mattmc3/zephyr ${ZDOTDIR:-~}/.zephyr

# source zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh

# choose your prompt
prompt starship
```

## Plugins

Below is the recommended plugin load order, and links to documentation for each plugin included in Zephyr.

- [environment](plugins/environment/readme.md)
- [terminal](plugins/terminal/readme.md)
- [editor](plugins/editor/readme.md)
- [history](plugins/history/readme.md)
- [directory](plugins/directory/readme.md)
- [utility](plugins/utility/readme.md)
- [zfunctions](plugins/zfunctions/readme.md)
- [confd](plugins/confd/readme.md)
- [completions](plugins/completions/readme.md)
- [autosuggestions](plugins/autosuggestions/readme.md)
- [prompt](plugins/prompt/readme.md)
- [syntax-highlighting](plugins/syntax-highlighting/readme.md)
- [history-substring-search](plugins/history-substring-search/readme.md)

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

### Prompts

Zephyr supports the Zsh built-in prompt command, and including the prompt plugin will run [promptinit]. Zephyr comes with the [starship] prompt, but you can use whatever prompt you want.

To change your prompt, you simply call `prompt $theme` after sourcing Zephyr in your `.zshrc`.

For example:

```zsh
# .zshrc
prompt starship
```

## Credits

Zephyr is a derivative work of the following great projects:

- [Oh-My-Zsh][ohmyzsh]
- [Prezto][prezto]
- [zsh-utils][zsh-utils]
- [fish][fish]


[antidote]:    https://getantidote.github.io
[fish]:        https://fishshell.com
[ohmyzsh]:     https://github.com/ohmyzsh/ohmyzsh
[prezto]:      https://github.com/sorin-ionescu/prezto
[promptinit]:  https://github.com/zsh-users/zsh/blob/master/Functions/Prompts/promptinit
[starship]:    https://starship.rs
[zsh-utils]:   https://github.com/belak/zsh-utils
