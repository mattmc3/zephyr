# string length - print the length of strings

Setup

```sh
$ PATH="$PATH:$PWD/bin"
$
```

Test string-length passes shellcheck

```sh
$ shellcheck --shell bash ./bin/string-length
$
```

Test that string-length works

```sh
$ string-length || echo "exit code: $?"
exit code: 1
$ string-length a bb ccc
1
2
3
$ printf '%s\n' foo bar baz | string-length
3
3
3
$ printf '%s\n' foo bar baz | string-length -q; echo "exit code: $?"
exit code: 0
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
