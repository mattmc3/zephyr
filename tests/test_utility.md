# Utility

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:utility' loaded || echo "not loaded"
not loaded
% test $+functions[bracketed-paste-url-magic] = 0  #=> --exit 0
% test $+functions[url-quote-magic] = 0  #=> --exit 0
% test $+functions[sedi] = 0  #=> --exit 0
% set -o | grep -v off | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/utility/utility.plugin.zsh
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:utility' loaded || echo "not loaded"
% test $+functions[bracketed-paste-url-magic] = 1  #=> --exit 0
% test $+functions[url-quote-magic] = 1  #=> --exit 0
% test $+functions[sedi] = 1  #=> --exit 0
% set -o | grep -v off | awk '{print $1}' | sort
autoresume
extendedglob
interactivecomments
longlistjobs
nobgnice
nocheckjobs
nohashdirs
nohup
norcs
%
```

Teardown

```zsh
% t_teardown
%
```
