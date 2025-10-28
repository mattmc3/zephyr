# string-transform - transform strings

Setup

```sh
$ PATH="$PATH:$PWD/bin"
$
```

Test string-transform passes shellcheck

```sh
$ shellcheck --shell bash ./bin/string-transform
$
```

Test that string lower works

```sh
$ string-lower FOO Bar baz
foo
bar
baz
$ printf '%s\n' FOO Bar baz | string-lower
foo
bar
baz
$
```

Test that string upper works

```sh
$ string-upper FOO Bar baz
FOO
BAR
BAZ
$ printf '%s\n' FOO Bar baz | string-upper
FOO
BAR
BAZ
$
```

No args exits with error code

```sh
$ # no args
$ string-lower || echo "exit code: $?"
exit code: 1
$ string-upper || echo "exit code: $?"
exit code: 1
$
```

Quiet mode exits correctly and prints nothing

```sh
$ string-lower --quiet A B C; echo "exit code: $?"
exit code: 0
$ string-lower --quiet a b c; echo "exit code: $?"
exit code: 1
$ string-upper --quiet A B C; echo "exit code: $?"
exit code: 1
$ string-upper --quiet a b c; echo "exit code: $?"
exit code: 0
$
```

Mimic Fish's own tests from [string.fish](https://github.com/fish-shell/fish-shell/blob/master/tests/checks/string.fish)

```sh
$ x=($(string-lower abc DEF gHi)) || echo string lower exit 1
$ [[ ${x[0]} = abc && ${x[1]} = def && ${x[2]} = ghi ]] || echo strings not converted to lowercase
$
$ x=$(echo abc DEF gHi | string-lower) || echo string lower exit 1
$ [[ "$x" = "abc def ghi" ]] || echo strings not converted to lowercase
$
$ string lower -q abc && echo lowercasing a lowercase string did not fail as expected
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
