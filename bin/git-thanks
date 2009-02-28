#!/bin/sh
# Usage: git-thanks <since>..<until>
#
# All commits on master, ever:
#   git-thanks master
#
# All commits on master since the 0.9.0 tag:
#   git-thanks 0.9.0..master

git log "$1" |
  grep Author: |
  sed 's/Author: \(.*\) <.*/\1/' |
  sort |
  uniq -c |
  sort -rn |
  sed 's/ *\([0-9]\{1,\}\) \(.*\)/\2 (\1)/'