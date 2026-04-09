# homebrew

> Zsh goodies for Homebrew users.

## Description

Sets `brew` environment variables from `brew shellenv` and adds brewed completions to `fpath`.

## Options

This plugin sets no Zsh options.

## Functions

This plugin sets no functions.

## Aliases

This plugin adds the following aliases:

| alias      | description                           |
| ---------- | ------------------------------------- |
| `brewdeps` | Show brewed formulae and dependencies |
| `brewinfo` | Show descriptions of brew installs    |
| `brewup`   | brew update/upgrade/cleanup           |

## Variables

This plugin sets the following variables:

| variable                | description                               |
| ----------------------- | ----------------------------------------- |
| `HOMEBREW_NO_ANALYTICS` | Disable Homebrew analytics (default: `1`) |

## Customizations

To cache the results of `brew shellenv`:

`zstyle ':zephyr:plugin:homebrew' 'use-cache' 'yes'`

To set keg-only brews whose completions are added to `fpath` (default: `curl ruby sqlite`):

`zstyle ':zephyr:plugin:homebrew' 'keg-only-brews' 'curl ruby sqlite'`

To skip setting homebrew aliases:

`zstyle ':zephyr:plugin:homebrew:alias' 'skip' 'yes'`
