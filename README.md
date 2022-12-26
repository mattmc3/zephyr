# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where Zephyr comes in. Zephyr is a lightweight framework designed to enhance Zsh by setting better options, completions, keybindings, history, and much more.

Zephyr can be thought of as a fast, lightweight set of core Zsh plugins. It contains a lot of the base functionality from frameworks like Oh-My-Zsh and Prezto without all the bloat. Combine Zephyr with a [plugin manager][antidote] and some [awesome plugins](https://github.com/unixorn/awesome-zsh-plugins) and you'll have a powerful Zsh setup that rivals anything out there.

## Install

### Using a Plugin manager

Use [antidote] to load Zephyr:

```shell
antidote install mattmc3/zephyr
```

Or, use [antidote] to only load the parts of Zephyr you need:

```shell
# .zsh_plugins.txt
mattmc3/zephyr path:plugins/$ZEPHYR_HOME/.external
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

- autosuggestions - Fish-like autosuggestions for zsh
- \*colors - sets variables and add functions related to shell colors
- confd - source conf.d like Fish
- \*completion - load and initialize the built-in zsh completion system
- \*directory - sets options and aliases related to the dirstack and directories
- \*editor - override and fill in the gaps of the default keybinds
- \*environment - sets general shell options and defines environment variables
- \*history - load and initilize the built-in zsh history system
- \*history-substring-search - port of Fish history search (up arrow)
- \*prompt - load and initialize the build-in zsh prompt system
- \*utility - common shell utilities, aimed at making cross platform work less painful
- syntax-highlighting - Fish shell like syntax highlighting for Zsh
- zfunctions - lazy load functions dir like Fish

\* loaded by default

## External plugins

Zephyr accomplishes a lot of its magic by pulling together core plugins from:

- [belak/zsh-utils][zsh-utils]
- [romkatv/zsh-bench][zsh-bench]
- [zsh-users/zsh-autosuggestions][zsh-autosuggestions]
- [zsh-users/zsh-completions][zsh-completions]
- [zsh-users/zsh-history-substring-search][zsh-history-substring-search]
- [zsh-users/zsh-syntax-highlighting][zsh-syntax-highlighting]

## Configuration

XDG base directory locations are used for `$HISTFILE` in the history plugin, and `$ZSH_COMPDUMP` in the $ZEPHYR_HOME/.external plugin.

To NOT use XDG base directory locations, set the following zstyle:

```zsh
zstyle ':zephyr:*:*' use-xdg-basedirs 'no'
```

Or, you can set it for each individual plugin:

```zsh
zstyle ':zephyr:plugins:history' use-xdg-basedirs 'no'
zstyle ':zephyr:plugins:$ZEPHYR_HOME/.external' use-xdg-basedirs 'yes'
```

## Credits

Zephyr is a derivative work of the following great projects:

- [Oh-My-Zsh][ohmyzsh]
- [Prezto][prezto]
- [zsh-utils][zsh-utils]


[antidote]: https://getantidote.github.io
[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[prezto]: https://github.com/sorin-ionescu/prezto
[zsh-utils]: https://github.com/belak/zsh-utils
[zsh-bench]: https://github.com/romkatv/zsh-bench
[zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[zsh-completions]: https://github.com/zsh-users/zsh-completions
[zsh-history-substring-search]: https://github.com/zsh-users/zsh-history-subsring-search
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
