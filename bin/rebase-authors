#!/usr/bin/env bash
set -e

while read action sha other; do
  if [ -n "$action" ]; then
    echo -n "$action "
    git show $sha --format="%h [%an] %s" -s
  else
    echo
  fi
done
