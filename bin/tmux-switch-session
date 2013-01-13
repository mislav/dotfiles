#!/usr/bin/env bash
# Usage: tmux-switch-session [<name>]
#
# Switches to the tmux session that starts with the name given, or to the
# previously attached session when name is blank.

set -e

if [[ $1 = "-h" || $1 = "--help" ]]; then
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit
fi

if [[ -z $1 ]]; then
  tmux switch-client -l
else
  tmux switch-client -t "$1"
fi
