# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where Zephyr comes in. Zephyr uses built-in Zsh features to set up better default options, completions, keybindings, history, and much more.

Zephyr can be thought of as a fast, lightweight alternative to big bloated Zsh frameworks like Oh-My-Zsh and Prezto. Combine Zephyr with a [plugin manager][antidote] and you'll have a powerful Zsh setup that rivals anything out there.

## Install

### Using a Plugin manager

Use [antidote] to load Zephyr:

```shell
antidote install mattmc3/zephyr
```

Or, use [antidote] to only load the parts of Zephyr you need:

```shell
# .zsh_plugins.txt
mattmc3/zephyr path:plugins/completions
mattmc3/zephyr path:plugins/directory
mattmc3/zephyr path:plugins/environment
mattmc3/zephyr path:plugins/history
```

### Manually

Add the following snippet to your `.zshrc`:

```zsh
# clone zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone https://github.com/mattmc3/zephyr ${ZDOTDIR:-~}/.zephyr

# source zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh
```

## Plugins

Below is the recommended plugin load order, and links to documentation for each plugin included in Zephyr.

- [colors](plugins/colors/readme.md)
- [completions](plugins/completions/readme.md)
- [directory](plugins/directory/readme.md)
- [editor](plugins/editor/readme.md)
- [environment](plugins/environment/readme.md)
- [history](plugins/history/readme.md)

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
