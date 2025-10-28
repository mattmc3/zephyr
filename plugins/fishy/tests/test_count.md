# count - count the number of elements of a list

Setup

```sh
$ PATH="$PATH:$PWD/bin"
$
```

Test count passes shellcheck

```sh
$ shellcheck --shell bash ./bin/count
$
```

Test that count will count args

```sh
$ count
0
$ count foo bar baz
3
$
```

Test that count will count piped data

```sh
$ printf '%s\n' foo bar baz | count
3
$
```

Mimic Fish's own tests from [count.fish](https://github.com/fish-shell/fish-shell/blob/master/tests/checks/count.fish)

```sh
$ # no args
$ count
0
$
$ # one args
$ count x
1
$
$ # two args
$ count x y
2
$
$ # args that look like flags or are otherwise special
$ count -h
1
$ count --help
1
$ count --
1
$ count -- abc
2
$ count def -- abc
3
$ # big counts
$ arr=($(seq 1 10000))
$ echo ${#arr[@]}
10000
$ count ${arr[@]}
10000
$ printf '%s\n' "${arr[@]}" | count
10000
$
$ # stdin
$ # Reading from stdin still counts the arguments
$ printf '%s\n' 1 2 3 4 5 | count 6 7 8 9 10
10
$
$ # Reading from stdin counts newlines - like `wc -l`.
$ echo -n 0 | count
0
$
$ echo 1 | count
1
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
