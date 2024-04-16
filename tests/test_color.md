# Color

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% test $+functions[colors] = 0  #=> --exit 0
% printf '%s\n' ${(q)LESS_TERMCAP_md}
''
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/color/color.plugin.zsh
%
```

Test plugin is initialized

```zsh
% test $+functions[colors] = 0  #=> --exit 1
% printf '%s\n' ${(q)LESS_TERMCAP_md}
$'\033'\[01\;34m
%
```

Teardown

```zsh
% t_teardown
%
```
