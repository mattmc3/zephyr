# homebrew

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:homebrew' loaded || echo "not loaded"
not loaded
% test $+aliases[brewup] = 0  #=> --exit 0
% test $+aliases[brewinfo] = 0  #=> --exit 0
% test $+functions[brews] = 0  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:homebrew' loaded || echo "not loaded"
% test $+aliases[brewup] = 1  #=> --exit 0
% test $+aliases[brewinfo] = 1  #=> --exit 0
% test $+functions[brews] = 1  #=> --exit 0
% set -o | grep 'on$' | sort
extendedglob          on
interactivecomments   on
nohashdirs            on
norcs                 on
%
```

Teardown

```zsh
% t_teardown
%
```
