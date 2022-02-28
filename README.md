# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Tired of slow, bloated, outdated Zsh frameworks? Want something that works great
out-of-the-box, is crazy fast, is a breeze to set up, has all the features of a modern
shell, and grows with you on your Zsh journey? You're in the right place.

## Installation

Add the following snippet to your `.zshrc`:

```zsh
# clone and source zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone https://github.com/zshzoo/zephyr ${ZDOTDIR:-~}/.zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh
```

## Customizing

Zephyr uses zstyles for customization. But, it doesn't require any configuration at all
to work out-of-the-box. However, you will probably find that it's nice to customize as
you use it over time.

## Plugins

Zephyr comes with a highly curated set of of plugins by default, and doesn't come with
everything out there. The goal is a great out-of-the-box Zsh experience for most people
with the base configuration that you can build on.

However, you might decide you don't want to load everything Zephyr includes, or you
might want to add some 3rd party plugins yourself. Never fear - you can easily customize
which plugins are loaded with the following zstyles:

### Plugins

Load (source) regular Zsh plugins with `zstyle ':zephyr:load' plugins $zplugins`:

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
cplugins=(
  # this isn't a Zsh plugin, but maybe we want it cloned
  # to set up our terminal color scheme
  mbadolato/iTerm2-Color-Schemes

  # this is a prompt, not a plugin, so clone it and add to fpath
  sindresorhus/pure

  # this isn't a Zsh plugin, but we want to add it to our $PATH
  romkatv/zsh-bench
)
zstyle ':zephyr:clone' plugins $cplugins
path=($path $ZEPHYRDIR/.external/zsh-bench)
fpath=($fpath $ZEPHYRDIR/.external/pure)
```

### Deferred Plugins

Some plugins are slow to load or you don't need them to be active right away. You can
specify plugins to deferred load with this Zstyle:

```zsh
# these plugins are slow or we don't need them right away, so let's defer their load
dplugins=(
  olets/zsh-abbr
  zdharma-continuum/fast-syntax-highlighting
)
zstyle ':zephyr:defer' plugins $dplugins
```

## Syntax Highlighting

To use [zsh-syntax-highlighting] instead of [fast-syntax-highlighting] add the following
to your `.zshrc` before sourcing Zephyr:

```zsh
zstyle ':zephyr:plugin:syntax-highlighting' repo 'zsh-users/zsh-syntax-highlighting'
```

Loading syntax highlighting is deferred. If you don't want to defer loading, you can
disable that like this:

```zsh
zstyle ':zephyr:plugin:syntax-highlighting' defer 'no'
```

## External Plugins

The following curated list of external plugins is available with Zephyr:

**Prompts:**
- [pure]
- [powerlevel10k]
- [Oh-My-Zsh themes][ohmyzsh-themes]

**Plugins:**
- Syntax highlighting via [fast-syntax-highlighting]
- Auto suggestions via [zsh-autosuggestions]
- History substring search via [zsh-history-substring-search]
- Additional completions via [zsh-completions]

**Utilities:**
- [zsh-defer]
- [zsh-bench]

[fast-syntax-highlighting]:      https://github.com/zdharma-continuum/fast-syntax-highlighting
[ohmyzsh-themes]:                https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
[powerlevel10k]:                 https://github.com/romkatv/powerlevel10k
[pure]:                          https://github.com/sindresorhus/pure
[zsh-autosuggestions]:           https://github.com/zsh-users/zsh-autosuggestions
[zsh-completions]:               https://github.com/zsh-users/zsh-completions
[zsh-bench]:                     https://github.com/romkatv/zsh-bench
[zsh-defer]:                     https://github.com/romkatv/zsh-defer
[zsh-history-substring-search]:  https://github.com/zsh-users/zsh-history-substring-search
[zsh-syntax-highlighting]:       https://github.com/zsh-users/zsh-syntax-highlighting
