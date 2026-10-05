# Directory

> Set features related to Zsh directories and dirstack.

## Options

This plugin sets the following Zsh options:

| action   | option                      | description                                                  |
| -------- | --------------------------- | ------------------------------------------------------------ |
| setopt   | [AUTO_PUSHD][16.2.1]        | Make cd push the old directory onto the dirstack.            |
| setopt   | [PUSHD_IGNORE_DUPS][16.2.1] | Don't push multiple copies of a directory onto the dirstack. |
| setopt   | [PUSHD_MINUS][16.2.1]       | Exchanges meanings of +/- when navigating the dirstack.      |
| setopt   | [PUSHD_SILENT][16.2.1]      | Do not print the directory stack after pushd or popd.        |
| setopt   | [PUSHD_TO_HOME][16.2.1]     | Push to home directory when no argument is given.            |
| setopt   | [EXTENDED_GLOB][16.2.3]     | Use extended chars (#,~,^) in globbing patterns.             |
| setopt   | [GLOB_DOTS][16.2.3]         | Include dotfiles when globbing.                              |
| unsetopt | [CLOBBER][16.2.6]           | Don't overwrite files with >. Use >! to bypass.              |
| unsetopt | [RM_STAR_SILENT][16.2.6]    | Ask for confirmation for `rm *' or `rm path/\*'              |
| setopt   | [MULTIOS][16.2.9]           | Write to multiple descriptors.                               |

## Functions

This plugin adds the following functions:

| function      | description                                      |
| ------------- | ------------------------------------------------ |
| `up <num>`    | Quickly go up any number of directories          |
| `prevd [num]` | Go back through the directory history, like Fish |
| `nextd [num]` | Go forward through the directory history         |

## Directory history

`prevd` and `nextd` walk the directories you have been in, as Fish does. `auto_pushd`
records them, so the history is the dirstack `dirh` prints, and walking off either end
wraps around. With the editor plugin loaded, Alt-Left and Alt-Right on an empty line
call them for you.

## Aliases

This plugin adds/modifies the following aliases:

| alias         | description                                                   |
| ------------- | ------------------------------------------------------------- |
| `-`           | `cd -`: dirstack navigation                                   |
| `dirh`        | `dirs -v`: show the dirstack                                  |
| `..1` - `..9` | suffix alias to perform actions up the dir tree (eg `ls ..3`) |
| `1` - `9`     | `cd -9`: quickly navigate the dirstack                        |

## Variables

This plugin sets no variables.

## Customizations

To skip setting directory related aliases, you can set:

`zstyle ':zephyr:plugin:directory:alias' 'skip' 'yes'`

To always skip aliases, you can set:

`zstyle ':zephyr:plugin:*:alias' 'skip' 'yes'`

To skip directory history, you can set:

`zstyle ':zephyr:plugin:directory:dirhistory' 'skip' 'yes'`

[16.2.1]: https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
[16.2.3]: https://zsh.sourceforge.io/Doc/Release/Options.html#Expansion-and-Globbing
[16.2.6]: https://zsh.sourceforge.io/Doc/Release/Options.html#Input_002fOutput
[16.2.9]: https://zsh.sourceforge.io/Doc/Release/Options.html#Scripts-and-Functions
