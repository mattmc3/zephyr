##? zephyr - A Zsh framework as nice as a cool summer breeze
##?
##?	Usage: make <command>
##?
##?	Commands:

.DEFAULT_GOAL := help
all : build help test submodules
.PHONY : all

##?   build       run build tasks
build:
	./bin/getupstream; \
	./bin/build_starship_completions

##?   test        run cli tests
test:
	./tests/runtests

##?   submodules  update all submodules
submodules:
	git submodule update --recursive --remote

##?   help        show this message
help:
	@grep "^##?" makefile | cut -c 5-
