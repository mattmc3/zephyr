# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where Zephyr comes in.

Zephyr combines some of the best functionality from [Prezto][prezto], sprinkles in a bit from [Oh-My-Zsh][ohmyzsh], and removes bloat and prioritizes speed and simplicity.

Zephyr can be thought of as a fast, lightweight set of essential Zsh plugins.

Combine Zephyr with a [plugin manager][antidote] and some [awesome plugins](https://github.com/unixorn/awesome-zsh-plugins) and you'll have a powerful Zsh setup that rivals anything out there.

## Install

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

### Manually

Add the following snippet to your `.zshrc`:

```zsh
# clone zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone --recursive https://github.com/mattmc3/zephyr ${ZDOTDIR:-~}/.zephyr

# source zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh
```

## Plugins

- **color** - Make terminal things more colorful
- **completion** - Load and initialize the built-in zsh completion system
- **confd** - Source conf.d like Fish
- **directory** - Set options and aliases related to the dirstack and filesystem
- **editor** - Override and fill in the gaps of the default keybinds
- **environment** - Define common environment variables
- **history** - Load and initilize the built-in zsh history system
- **homebrew** - Functionality for users of Homebrew
- **macos** - Functionality for macOS users
- **prompt** - Load and initialize the build-in zsh prompt system
- **terminal** - Set terminal window and tab titles
- **utility** - Common shell utilities, aimed at making cross platform work less painful
- **zfunctions** - Lazy load functions dir like Fish

## Why don't you include...

_Q: Why don't you include programming language plugins (eg: Python, Ruby)?_
A: These kinds of plugins can be very opinionated, and are in need of lots of upkeep from maintainers that use those languages. Language plugins are already available via Oh-My-Zsh and Prezto, and can always be installed with [a plugin manager that supports subplugins][antidote].

_Q: Why don't you also include popular plugins the way Prezto does (eg: zsh-autosuggestions, zsh-completions)?_
A: These kinds of utilities are already available as stand-alone plugins. Zephyr aims to include only core Zsh functionality that you can't already easily get via a [plugin manager][antidote], with a few exceptions for convenience. I have experimented with including submodules like Prezto, but was not happy with the result. Simpler is better.

## Credits

Zephyr is a derivative work of the following great projects:

- [Oh-My-Zsh][ohmyzsh]
- [Prezto][prezto]
- [zsh-utils][zsh-utils]


[antidote]: https://getantidote.github.io
[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[prezto]: https://github.com/sorin-ionescu/prezto
[zsh-utils]: https://github.com/belak/zsh-utils
