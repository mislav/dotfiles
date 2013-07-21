#!/usr/bin/env bash
# Like `tmux select-pane`, but if Vim is running in the current pane it sends
# a `<C-h/j/k/l>` keystroke to Vim instead.
set -e

cmd="$(tmux display -p '#{pane_current_command}')"
cmd="$(basename "$cmd" | tr A-Z a-z)"

if [ "${cmd%m}" = "vi" ]; then
  direction="$(echo "${1#-}" | tr 'lLDUR' '\\hjkl')"
  # forward the keystroke to Vim
  tmux send-keys "C-$direction"
else
  tmux select-pane "$@"
fi
