# helper

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:helper' loaded || echo "not loaded"
not loaded
% test $+functions[is-autoloadable] = 0  #=> --exit 0
% test $+functions[is-callable] = 0  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/helper/helper.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:helper' loaded || echo "not loaded"
% test $+functions[is-autoloadable] = 1  #=> --exit 0
% test $+functions[is-callable] = 1  #=> --exit 0
% set -o | grep 'on$' | sort
nohashdirs            on
norcs                 on
%
```

Teardown

```zsh
% t_teardown
%
```
