#!/usr/bin/env bash
# Usage: git longest-message [<branch>]
#
# Displays 5 of your commits with most words per commit message body.

set -e

git rev-list --author="$(git config user.name)" --no-merges "${1:-HEAD}" | \
  while read rev; do
    echo "$(git show -s --format='%b' $rev | wc -w) words: $rev"
  done | \
    sort -rn | head -5
