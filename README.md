# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where Zephyr comes in.

Zephyr combines some of the best functionality from [Prezto][prezto], sprinkles in a bit from [Oh-My-Zsh][ohmyzsh], and removes any bloat and prioritizes speed and simplicity.

Zephyr can be thought of as a fast, lightweight set of essential Zsh plugins.

Combine Zephyr with a [plugin manager][antidote] and some [awesome plugins](https://github.com/unixorn/awesome-zsh-plugins) and you'll have a powerful Zsh setup that rivals anything out there.

## Install

Add the following snippet to your `.zshrc`:

```zsh
# clone zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone --recursive https://github.com/mattmc3/zephyr ${ZDOTDIR:-~}/.zephyr

# source zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh
```

### Using a Plugin manager

If your plugin manager supports using sub-plugins, you can load Zephyr that way as well.

[Antidote][antidote] is one such plugin manager. You can load only the parts of Zephyr you need like so:

```shell
# .zsh_plugins.txt
mattmc3/zephyr path:plugins/directory
mattmc3/zephyr path:plugins/editor
mattmc3/zephyr path:plugins/history
mattmc3/zephyr path:plugins/completion
```

## Plugins

- [autosuggestions][zsh-autosuggestions] - Fish-like autosuggestions for zsh
- clipboard - Handy cross-platform clipboard functions
- colors\* - Make terminal things more colorful
- completion\* - Load and initialize the built-in zsh completion system
- confd - Source conf.d like Fish
- directory\* - Sets options and aliases related to the dirstack and directories
- editor\* - Override and fill in the gaps of the default keybinds
- environment\* - Sets general shell options and defines environment variables
- history\* - Load and initilize the built-in zsh history system
- [history-substring-search][zsh-history-substring-search]\* - Port of Fish history search (up arrow)
- prompt\* - Load and initialize the build-in zsh prompt system
- [syntax-highlighting][fast-syntax-highlighting] - Feature-rich syntax highlighting for Zsh
- utility\* - Common shell utilities, aimed at making cross platform work less painful
- zfunctions\* - Lazy load functions dir like Fish
- [z] - Jump around.

\* loaded by default

## External plugins

Zephyr accomplishes a lot of its magic by pulling together core plugins from:

- [belak/zsh-utils][zsh-utils]
- [romkatv/zsh-bench][zsh-bench]
- [zsh-users/zsh-autosuggestions][zsh-autosuggestions]
- [zsh-users/zsh-completions][zsh-completions]
- [zsh-users/zsh-history-substring-search][zsh-history-substring-search]
- [zsh-users/zsh-syntax-highlighting][zsh-syntax-highlighting]
- [zdharma-continuum/fast-syntax-highlighting][fast-syntax-highlighting]

## Configuration

XDG base directory locations are used for `$HISTFILE` in the history plugin, and `$ZSH_COMPDUMP` in the completion plugin.

To NOT use XDG base directory locations, set the following zstyle:

```zsh
zstyle ':zephyr:*:*' use-xdg-basedirs 'no'
```

Or, you can set it for each individual plugin:

```zsh
zstyle ':zephyr:plugins:history' use-xdg-basedirs 'no'
zstyle ':zephyr:plugins:completion' use-xdg-basedirs 'yes'
```

## Credits

Zephyr is a derivative work of the following great projects:

- [Oh-My-Zsh][ohmyzsh]
- [Prezto][prezto]
- [zsh-utils][zsh-utils]


[antidote]: https://getantidote.github.io
[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[prezto]: https://github.com/sorin-ionescu/prezto
[fast-syntax-highlighting]: https://github.com/zdharma-continuum/fast-syntax-highlighting
[zsh-utils]: https://github.com/belak/zsh-utils
[zsh-bench]: https://github.com/romkatv/zsh-bench
[zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[zsh-completions]: https://github.com/zsh-users/zsh-completions
[zsh-history-substring-search]: https://github.com/zsh-users/zsh-history-subsring-search
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
[z]: https://github.com/rupa/z
