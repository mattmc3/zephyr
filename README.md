# :wind_face: Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a boost. That's where Zephyr comes
in.

Zephyr combines some of the best parts from [Prezto][prezto] and other Zsh frameworks,
removes bloat and dependencies, and prioritizes speed and simplicity.

Zephyr can be thought of as a fast, lightweight set of independent Zsh features, and is
designed to be one of the first things you load to build your ideal Zsh config.

Combine Zephyr with a [plugin manager][antidote] and some [awesome
plugins](https://github.com/unixorn/awesome-zsh-plugins) and you'll have a powerful Zsh
setup that rivals anything out there.

## Project goals

Zephyr allows you to take an _a la carte_ approach to building your ideal Zsh
configuration. Other Zsh frameworks are meant to be used wholesale and are not truly
modular. Zephyr is different - each of its plugins works independently, and are designed
to pair well with a modern Zsh plugin manager like [antidote]. Zephyr can be used in
whole or in part, and plays nice with other popular plugins. Zephyr brings together core
Zsh functionality that typically is not available elsewhere as standalone plugins -
while favoring a build-your-own composable Zsh config.

## Prompt

Zephyr comes with an (optional) [Starship][starship] prompt config.

![Zephyr Prompt][terminal-img]

## Install

### Using a Plugin manager

If your plugin manager supports using sub-plugins, you can load Zephyr that way as well.

[Antidote][antidote] is one such plugin manager. You can load only the parts of Zephyr you need like so:

```shell
# .zsh_plugins.txt
# pick only the plugins you want and remove the rest
mattmc3/zephyr path:plugins/color
mattmc3/zephyr path:plugins/completion
mattmc3/zephyr path:plugins/compstyle
mattmc3/zephyr path:plugins/confd
mattmc3/zephyr path:plugins/directory
mattmc3/zephyr path:plugins/editor
mattmc3/zephyr path:plugins/environment
mattmc3/zephyr path:plugins/history
mattmc3/zephyr path:plugins/homebrew
mattmc3/zephyr path:plugins/macos
mattmc3/zephyr path:plugins/prompt
mattmc3/zephyr path:plugins/utility
mattmc3/zephyr path:plugins/zfunctions
```

### Manually

Add the following snippet to your `.zshrc`:

```zsh
# Clone Zephyr.
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone --depth=1 https://github.com/mattmc3/zephyr ${ZDOTDIR:-~}/.zephyr

# Use zstyle to specify which plugins you want. Order matters.
zephyr_plugins=(
  zfunctions
  directory
  editor
  history
)
zstyle ':zephyr:load' plugins $zephyr_plugins

# Source Zephyr.
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh
```

## Plugins

- **color** - Make terminal things more colorful
- **completion** - Load and initialize the built-in zsh completion system
- **compstyle** - Load and initialize a completion style system
- **confd** - Source a Fish-like `conf.d` directory
- **directory** - Set options and aliases related to the dirstack and filesystem
- **editor** - Override and fill in the gaps of the default keybinds
- **environment** - Define common environment variables
- **history** - Load and initialize the built-in zsh history system
- **homebrew** - Functionality for users of Homebrew
- **macos** - Functionality for macOS users
- **prompt** - Load and initialize the built-in zsh prompt system
- **utility** - Common shell utilities, aimed at making cross platform work less painful
- **zfunctions** - Lazy load a Fish-like functions directory

## Why don't you include...

_Q: Why don't you include programming language plugins (eg: Python, Ruby)?_ \
**A:** These kinds of plugins can be very opinionated, and are in need of lots of upkeep
from maintainers that use those languages. Language plugins are already available via
Oh-My-Zsh and Prezto, and can always be installed with [a plugin manager that supports
subplugins][antidote].

_Q: Why don't you also include popular plugins the way Prezto does (eg:
zsh-autosuggestions, zsh-history-substring-search)?_ \
**A:** These kinds of utilities are already
available as standalone plugins. Zephyr aims to include only core Zsh functionality that
you can't already easily get via a [plugin manager][antidote], with a few exceptions for
convenience. I have experimented with including submodules similar to Prezto, but was
not happy with the result. Simpler is better.

## Credits

Zephyr is a derivative work of the following great projects:

- [Prezto][prezto] - [MIT License][prezto-license]
- [zsh-utils][zsh-utils] - [MIT License][zsh-utils-license]
- [Oh-My-Zsh][ohmyzsh] - [MIT License][ohmyzsh-license]

[antidote]:           https://antidote.sh
[ohmyzsh]:            https://github.com/ohmyzsh/ohmyzsh
[ohmyzsh-license]:    https://github.com/ohmyzsh/ohmyzsh/blob/master/LICENSE.txt
[prezto]:             https://github.com/sorin-ionescu/prezto
[prezto-license]:     https://github.com/sorin-ionescu/prezto/blob/master/LICENSE
[zsh-utils]:          https://github.com/belak/zsh-utils
[zsh-utils-license]:  https://github.com/belak/zsh-utils/blob/main/LICENSE
[terminal-img]:       https://raw.githubusercontent.com/mattmc3/zephyr/resources/img/terminal.png
[starship]:           https://starship.rs
