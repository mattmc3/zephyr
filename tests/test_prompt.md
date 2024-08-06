# prompt

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:prompt' loaded || echo "not loaded"
not loaded
% test $+functions[run_promptinit] = 0  #=> --exit 0
% test $+functions[hooks-add-hook] = 0  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:prompt' loaded || echo "not loaded"
% test $+functions[run_promptinit] = 1  #=> --exit 0
% hooks-add-hook -L post_zshrc run-promptinit-post-zshrc
typeset -g -a post_zshrc=( run-promptinit-post-zshrc )
% set -o | grep 'on$' | sort
extendedglob          on
interactivecomments   on
nohashdirs            on
norcs                 on
promptsubst           on
%
```

Teardown

```zsh
% t_teardown
%
```
