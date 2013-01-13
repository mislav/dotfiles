#!/bin/sh
# Summary: Lock the current rbenv version for the current directory
# Writes the current Ruby version (possibly set by `rbenv global` or `rbenv shell`)
# to `rbenv local`, effectively "locking" the Ruby version for the current project.
rbenv local "$(rbenv version-name)"
