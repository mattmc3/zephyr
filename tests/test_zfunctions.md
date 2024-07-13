# zfunctions

Init

```zsh
% source ./tests/__init__.zsh
%
```

Test plugin is not initialized

```zsh
% test $+functions[autoload-dir] = 0 && echo "autoload-dir not defined"
autoload-dir not defined
% test $+functions[funced] = 0  #=> --exit 0
% test $+functions[funcsave] = 0  #=> --exit 0
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/zfunctions/zfunctions.plugin.zsh
%
```

Test plugin is initialized

```zsh
% test $+functions[autoload-dir] = 1  #=> --exit 0
% test $+functions[funced] = 1  #=> --exit 0
% test $+functions[funcsave] = 1  #=> --exit 0
%
```
