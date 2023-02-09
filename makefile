##? zephyr - A Zsh framework as nice as a cool summer breeze
##?
##?	Usage: make <command>
##?
##?	Commands:

.DEFAULT_GOAL := help
all : build help
.PHONY : all

##?   build    run build tasks
build:
	./bin/build_prezto_plugins; \
  ./bin/build_starship_completions

##?   help     show this message
help:
	@grep "^##?" makefile | cut -c 5-
