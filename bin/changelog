#!/bin/bash
# vi:ft=sh:
# Usage: changelog [<range>] [-- <directory> ...]
set -e

range="${1:-origin..}"
shift 1

git log --no-merges --format='%C(auto,green)* %s%C(auto,reset)%n%w(0,2,2)%+b' --reverse "$range" "$@"
