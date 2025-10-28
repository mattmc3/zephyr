# contains - test if a word is present in a list

Setup

```sh
$ PATH="$PATH:$PWD/bin"
$
```

Test contains passes shellcheck

```sh
$ shellcheck --shell bash ./bin/contains
$
```

Test contains prints its help

```sh
$ contains --help | head -n1
contains - test if a word is present in a list
$
```

Test that contains fails on no args

```sh
$ contains #=> --exit 1
$ contains
contains: key not specified
$
```

Test that contains finds nothing with needle but no haystack

```sh
$ contains foo #=> --exit 1
$ contains foo
$
```

Test that contains finds needles in the haystack

```sh
$ contains bar foo bar baz #=> --exit 0
$ contains --index bar foo bar baz
2
$
```

Mimic Fish's own tests from [basic.fish](https://github.com/fish-shell/fish-shell/blob/master/tests/checks/basic.fish)

```sh
#test contains -i
$ contains -i string a b c string d
4
$ contains -i string a b c d || echo nothing
nothing
$ contains -i -- string a b c string d
4
$ contains -i -- -- a b c || echo nothing
nothing
$ contains -i -- -- a b c -- v
4
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
