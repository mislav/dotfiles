#!/usr/bin/env bash
# Usage: tmux-ps <pattern>
#
# Switch to tmux window which hosts the tty that is controlling the process
# matching <pattern>.
set -e

window_with_tty() {
  tmux list-panes -a -F '#{pane_tty} #{session_name}:#{window_index}' \
    | grep "$1" | sort -u | head -1 | awk '{ print $2 }'
}

while read tty pid ppid cmd; do
  window_id="$(window_with_tty "$tty")"
  tmux select-window -t "$window_id"
  tmux switch-client -t "${window_id%:*}"
  break
done < <(ps -o 'tty=,pid=,ppid=,command=' | grep "$1" | grep -wv grep | grep -wv $$)
