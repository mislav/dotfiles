#!/usr/bin/env bash
# Like `tmux select-pane`, but if Vim is running in the current pane it sends a
# keystroke to Vim instead to let it decide whether it's going to switch windows
# internally or switch tmux panes.
set -e

# gets the tty of active tmux pane
active_tty="$(tmux list-panes -F '#{pane_active}#{pane_tty}' | grep '^1')"

# checks if there's a foreground Vim process in attached to that tty
if ps c -o 'state=,command=' -t "${active_tty#1}" | grep '+' | grep -iE '\bvim?\b' >/dev/null ; then
  direction="$(echo "${1#-}" | tr 'lLDUR' '\\hjkl')"
  # forward the keystroke to Vim
  tmux send-keys C-$direction
else
  tmux select-pane "$@"
fi
