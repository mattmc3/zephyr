# prompt

> Load and initialize the built-in zsh prompt system.

## Options

This plugin sets the following Zsh options:

| action | option                 | description                            |
| ------ | ---------------------- | -------------------------------------- |
| setopt | [PROMPT_SUBST][16.2.8] | Expand parameters in prompt variables. |

## Functions

This plugin adds the following functions:

| function                | description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| `promptinit`            | Wrapped version of the built-in that also registers p10k and starship. |
| `run_promptinit`        | Initialize the prompt system and set the configured theme.             |
| `prompt_p10k_setup`     | Hook to load Powerlevel10k via the prompt system.                      |
| `prompt_starship_setup` | Hook to load Starship via the prompt system.                           |

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets the following variables:

| variable | description                                            |
| -------- | ------------------------------------------------------ |
| `PS2`    | Continuation prompt (2-space indent per nesting level) |

## Customizations

To set the prompt theme:

`zstyle ':zephyr:plugin:prompt' 'theme' 'starship'`

To pass a theme argument (eg: a named Starship config or p10k config):

`zstyle ':zephyr:plugin:prompt' 'theme' 'starship' 'mytheme'`

To run promptinit immediately instead of deferring until after `.zshrc`:

`zstyle ':zephyr:plugin:prompt' 'immediate' 'yes'`

To cache the prompt initialization:

`zstyle ':zephyr:plugin:prompt' 'use-cache' 'yes'`

[16.2.8]: https://zsh.sourceforge.io/Doc/Release/Options.html#Prompting
