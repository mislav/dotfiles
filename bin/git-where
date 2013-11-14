#!/usr/bin/env bash
# Usage: git where <ref>
#
# Shows where a particular commit falls between releases.
set -e

[[ -z $1 ]] && abort=1 || abort=0

if [[ $abort -gt 0 || $1 = "-h" || $1 = "--help" ]]; then
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0" >&$((abort+1))
  exit $abort
fi

git describe --tags "$1"
git name-rev --tags --name-only "$1" --no-undefined 2>/dev/null ||
  echo "(unreleased)"
