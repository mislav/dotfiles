#!/usr/bin/env bash
# Usage: gitio URL [CODE]
#
# Copies the git.io URL to your clipboard.

set -e

url="${1}"
code="${2}"

[[ -z $url ]] && abort=1 || abort=0

if [[ $abort -gt 0 || $1 = "-h" || $1 = "--help" ]]; then
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0" >&$((abort+1))
  exit $abort
fi

if ! [[ $url =~ "github.com" ]]; then
  echo "only GitHub.com URLs are supported" >&2
  exit 1
fi

if [ -n "$code" ]; then
  if existing="$(curl -ifs "git.io/${code}" 2>/dev/null | grep -i '^Location:')"; then
    echo "Error: \`${code}' is already taken" >&2
    echo "$existing" >&2
    exit 1
  fi
fi

url="$(curl -ifsS git.io -d "url=$url" ${code:+-d code=$code} | awk '/^Location:/ { print $2 }')"

if [ -n "$url" ]; then
  tee <<<"$url" >(pbcopy)
else
  exit 1
fi
