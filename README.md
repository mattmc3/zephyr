# Zsh Zephyr

A Zsh framework as nice as a cool summer breeze

## Installation

Add the following snippet to your `.zshrc`:

```zsh
# .zshrc
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone https://github.com/zshzoo/zephyr ${ZDOTDIR:-~}/.zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh
```

## Customizing

Zephyr uses zstyles for customization. It doesn't require any configuartion at all to
work, but you will probably find that over time it's nice to customize.

## Plugins

Zephyr loads all its plugins by default. The goal is a great out-of-the-box Zsh
experience without a ton of configuration.

However, you might decide you don't want to load everything Zephyr includes, or you
might want to add some 3rd party plugins yourself. Never fear - you can easily customize
which plugins are loaded with the following zstyles:

### Regular Plugins

Source (load) regular Zsh plugins with `zstyle ':zephyr:load' plugins $zplugins`:

```zsh
# order matters
zplugins=(
  # zephyr plugins
  environment
  terminal
  editor
  history
  directory
  utility
  abbreviations
  autosuggestions
  history-substring-search
  prompt
  zfunctions

  # 3rd party plugins
  zshzoo/magic-enter
  zshzoo/macos
  rummik/zsh-tailf
  peterhurford/up.zsh
  rupa/z

  # load these last
  confd
  completions
  syntax-highlighting
)
zstyle ':zephyr:load' plugins $zplugins
```

### Clone-only Plugins

Some repos you might want to just clone and not try to source as a plugin. To do that,
add the following Zstyle:

```zsh
# this isn't a Zsh plugin, but maybe we want to use it another way
cplugins=(
  mbadolato/iTerm2-Color-Schemes
)
zstyle ':zephyr:clone' plugins $cplugins
```

### Deferred Plugins

Some plugins are slow to load or you don't need them to be active right away. You can
specify plugins to deferred load with this Zstyle:

```zsh
# the abbr plugin is slow, so let's defer its load
dplugins=(
  olets/zsh-abbr
)
zstyle ':zephyr:defer' plugins $dplugins
```

## Syntax Highlighting

To use [zdharma-continuum/fast-syntax-highlighting][fast-syntax-highlighting] instead
of the zsh-users syntax highlighter add the following to your `.zshrc` before sourcing
Zephyr:

```zsh
zstyle ':zephyr:plugin:syntax-highlighting' use-fast-syntax-highlighting 'yes'
```

[fast-syntax-highlighting]: https://github.com/zdharma-continuum/fast-syntax-highlighting
