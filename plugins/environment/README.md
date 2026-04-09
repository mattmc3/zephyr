# environment

> Define common environment variables.

## Options

This plugin sets the following Zsh options:

| action   | option                         | description                                                       |
| -------- | ------------------------------ | ----------------------------------------------------------------- |
| setopt   | [EXTENDED_GLOB][16.2.3]        | Use more awesome globbing features.                               |
| unsetopt | [RM_STAR_SILENT][16.2.6]       | Ask for confirmation for `rm *` or `rm path/*`.                   |
| setopt   | [COMBINING_CHARS][16.2.10]     | Combine zero-length chars with the base character (eg: accents).  |
| setopt   | [INTERACTIVE_COMMENTS][16.2.9] | Enable comments in interactive shell.                             |
| setopt   | [RC_QUOTES][16.2.9]            | Allow `'it''s'` instead of `'it'\''s'` for single-quoted strings. |
| unsetopt | [MAIL_WARNING][16.2.6]         | Don't print a warning when a mail file is accessed.               |
| unsetopt | [BEEP][16.2.6]                 | Don't beep on error in the line editor.                           |
| setopt   | [AUTO_RESUME][16.2.7]          | Attempt to resume existing job before creating a new process.     |
| setopt   | [LONG_LIST_JOBS][16.2.7]       | List jobs in the long format by default.                          |
| setopt   | [NOTIFY][16.2.7]               | Report status of background jobs immediately.                     |
| unsetopt | [BG_NICE][16.2.7]              | Don't run background jobs at a lower priority.                    |
| unsetopt | [CHECK_JOBS][16.2.7]           | Don't report on jobs when shell exits.                            |
| unsetopt | [HUP][16.2.7]                  | Don't kill jobs on shell exit.                                    |

## Functions

This plugin sets no functions.

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets the following variables:

| variable                 | description                                          |
| ------------------------ | ---------------------------------------------------- |
| `EDITOR`                 | Default editor (fallback: `nano`)                    |
| `VISUAL`                 | Default visual editor (fallback: `nano`)             |
| `PAGER`                  | Default pager (fallback: `less`)                     |
| `BROWSER`                | Default browser (macOS only, fallback: `open`)       |
| `LANG`                   | Default locale (fallback: `en_US.UTF-8`)             |
| `LESS`                   | Default Less options                                 |
| `LESSOPEN`               | Less input preprocessor command                      |
| `KEYTIMEOUT`             | Key sequence timeout in hundredths of a second       |
| `SHELL_SESSIONS_DISABLE` | Disable Apple Terminal session restore (macOS only)  |
| `XDG_CONFIG_HOME`        | XDG config directory (when use-xdg-basedirs enabled) |
| `XDG_CACHE_HOME`         | XDG cache directory (when use-xdg-basedirs enabled)  |
| `XDG_DATA_HOME`          | XDG data directory (when use-xdg-basedirs enabled)   |
| `XDG_STATE_HOME`         | XDG state directory (when use-xdg-basedirs enabled)  |

## Customizations

To set XDG base directories:

`zstyle ':zephyr:plugin:environment' 'use-xdg-basedirs' 'yes'`

To set a custom list of directories prepended to `$PATH`:

```zsh
zstyle ':zephyr:plugin:environment' 'prepath' \
  $HOME/bin \
  $HOME/.local/bin
```

[16.2.3]: https://zsh.sourceforge.io/Doc/Release/Options.html#Expansion-and-Globbing
[16.2.6]: https://zsh.sourceforge.io/Doc/Release/Options.html#Input_002fOutput
[16.2.7]: https://zsh.sourceforge.io/Doc/Release/Options.html#Job-Control
[16.2.9]: https://zsh.sourceforge.io/Doc/Release/Options.html#Scripts-and-Functions
[16.2.10]: https://zsh.sourceforge.io/Doc/Release/Options.html#Shell-Emulation
