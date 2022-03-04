# :wind_face: Zsh Zephyr

> A Zsh framework as nice as a cool summer breeze

Zsh is a wonderful shell, but out-of-the-box it needs a bit of a boost. That's where
Zephyr comes in. It's crazy fast, is a breeze to set up, brings modern features to your
shell, is easy to build from, and grows with you on your Zsh journey.

While other Zsh frameworks are outdated, slow, unmaintained, or over-complicated, Zephyr
should feel like a fresh breeze.

## Installation

Add the following snippet to your `.zshrc`:

```zsh
# clone zephyr
[[ -d ${ZDOTDIR:-~}/.zephyr ]] ||
  git clone https://github.com/zshzoo/zephyr ${ZDOTDIR:-~}/.zephyr

# source zephyr
source ${ZDOTDIR:-~}/.zephyr/zephyr.zsh

# initialize zephyr
zephyr init

# choose your prompt
prompt pure
```

## Goals

Zephyr's goals can be described as F.R.E.S.C.O:

- **Fast!** - Zephyr shouldn't bog down your Zsh
- **Reliable** - Zephyr updates should not break your Zsh config
- **Extendable** - Zephyr should grow with you
- **Simple** - Zephyr's out-of-the-box configuration should work well for most people
- **Configurable** - Zephyr should let you customize
- **Outstanding** - Zephyr should be a delight to use

## Features

- Auto suggestions via [zsh-autosuggestions]
- Robust command completions, including extras via [zsh-completions]
- Automatically source anything in a `${ZDOTDIR:-$HOME/.config/zsh}/conf.d` directory
- Autoload functions in a `${ZDOTDIR:-$HOME/.config/zsh}/functions` directory
- Better [Zsh options][zsh-setopts] than the defaults
- History substring search via [zsh-history-substring-search]
- Syntax highlighting via [zsh-syntax-highlighting]
- Great prompt support, including [pure]
- Great keybindings
- Terminal window enhancements
- Easily add your own plugins from GitHub

## Variables and functions

Zephyr won't clutter your Zsh with tons of extra variables and functions. Obviously, it
contains external plugins which will of course have their own variables and functions,
but Zephyr itself provides only a few, simple things:

|                  | purpose                         |
| ---------------- | ------------------------------- |
| `$ZEPHYRDIR`     | The install location for Zephyr |
| `zephyr`         | The command to manage Zephyr    |


## Customizing

Zephyr uses zstyles for customization. But, it doesn't require any configuration at all
to work out-of-the-box. However, over time you might find that it's nice to customize.

## Plugins

Zephyr comes with a highly curated set of of plugins by default, and doesn't come with
everything out there. The goal is a great out-of-the-box Zsh experience for most people
with a base configuration that you can easily build on. You may have noticed Zephyr has
a bit of a [fish shell][fish] bias - many of its plugins bring fish features to Zsh.

However, you might decide you don't want everything Zephyr includes, or you might want
to add some 3rd party plugins yourself. Never fear - you can easily customize which
plugins are loaded.

## .zephyr.plugins file

Zephyr will create a `$ZDOTDIR/.zephyr.plugins` file for you on init. In it, you can
list the plugins you want to load.

### Clone-only Plugins

You might want to just clone some repos and not try to source them as plugins. To do
that, add the `kind:clone` option to your plugin:

```zsh
# .zephyr.plugins
# this isn't a Zsh plugin, but maybe we want it cloned
# to set up our terminal color scheme
mbadolato/iTerm2-Color-Schemes kind:clone
```

### Prompt Plugins

Some plugins provide prompts or themes. To use a prompt plugin, add the `kind:prompt`
option:

```zsh
# this is a prompt, not a regular plugin
sindresorhus/pure kind:prompt
```

### $PATH Plugins

Some plugins provide utilities you want added to your path. To use a utility plugin like
this, add the `kind:path` option:

```zsh
# this is a utility, add it to our $PATH
romkatv/zsh-bench kind:path
```

### $fpath Plugins

Similar to $PATH plugins, you may have a plugin that you need added to your `fpath`:

```zsh
# this is a utility, add it to our $PATH
miekg/lean kind:fpath
```

### Deferred Plugins

*Note: [use with caution][deferred-init]*

Some plugins are slow to load or you don't need them to be active right away. You can
specify plugins to defer load with the `kind:defer` option:

```
# this is a slow but useful plugin that
# we don't need loaded right away
olets/zsh-abbr kind:defer
```

## Prompts

Zephyr supports the Zsh built-in prompt command, and including the prompt plugin will
run [promptinit]. Zephyr comes with a few popular prompts, including [pure] and
[starship].

To change your prompt, you simply call `prompt $theme` after sourcing Zephyr in your
`.zshrc`.

For example:

```zsh
# .zshrc
prompt pure
```

## Included 3rd Party Plugins

The following curated list of external plugins is available with Zephyr:

**Prompts:**
- [pure]
- [starship]

**Plugins:**
- Syntax highlighting via [zsh-syntax-highlighting]
- Auto suggestions via [zsh-autosuggestions]
- History substring search via [zsh-history-substring-search]
- Additional completions via [zsh-completions]

**Utilities:**
- [zsh-defer] - Defer loading certain plugins ([use with caution][deferred-init])
- [zsh-bench] - Benchmark your Zsh configuration

## Benchmarks

:wind_face: Zephyr is FAST! How fast? Here's the latest [zsh-bench] numbers from my
2020 MacBook Air M1 running macOS Monterey and zsh 5.8 with the default Zephyr config
and pure prompt:

```shell
==> benchmarking login shell of user zshzoo ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=1
has_autosuggestions=1
has_git_prompt=0
first_prompt_lag_ms=58.072
first_command_lag_ms=70.599
command_lag_ms=11.057
input_lag_ms=9.306
exit_time_ms=44.254
```

## Credits

Zephyr is a derivative work of the following great projects:

- [Oh-My-Zsh][ohmyzsh]
- [Prezto][prezto]
- [zsh-utils][zsh-utils]
- [fish][fish]


[fish]:                          https://fishshell.com
[deferred-init]:                 https://github.com/romkatv/zsh-bench#deferred-initialization
[ohmyzsh-themes]:                https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
[ohmyzsh]:                       https://github.com/ohmyzsh/ohmyzsh
[prezto]:                        https://github.com/sorin-ionescu/prezto
[promptinit]:                    https://github.com/zsh-users/zsh/blob/master/Functions/Prompts/promptinit
[pure]:                          https://github.com/sindresorhus/pure
[starship]:                      https://starship.rs
[zsh-autosuggestions]:           https://github.com/zsh-users/zsh-autosuggestions
[zsh-bench]:                     https://github.com/romkatv/zsh-bench
[zsh-completions]:               https://github.com/zsh-users/zsh-completions
[zsh-defer]:                     https://github.com/romkatv/zsh-defer
[zsh-history-substring-search]:  https://github.com/zsh-users/zsh-history-substring-search
[zsh-setopts]:                   https://zsh.sourceforge.io/Doc/Release/Options.html
[zsh-syntax-highlighting]:       https://github.com/zsh-users/zsh-syntax-highlighting
[zsh-utils]:                     https://github.com/belak/zsh-utils
