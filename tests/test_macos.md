# macos

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:macos' loaded || echo "not loaded"
not loaded
% test $+functions[cdf] = 0  #=> --exit 0
% test $+functions[trash] = 0  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/macos/macos.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:macos' loaded || echo "not loaded"
% test $+functions[cdf] = 1  #=> --exit 0
% test $+functions[trash] = 1  #=> --exit 0
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
