#!/usr/bin/env bash
# Usage: loc [<GITHUB-URL>] [bin lib libexec src]
#
# Count lines of code (excluding comments and blank lines) in given files and
# directories. With a GitHub project URL, it will download that project's
# source code and perform the search there.

set -e

sanitize() {
  printf "%s" "$1" | sed "s/[^A-Za-z0-9.-]/_/g; s/__*/_/g"
}

case "$1" in
-h|--help)
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
  exit 0
  ;;
esac

if [[ "$1" == "https://github.com/"* ]]; then
  url="${1}/archive/master.tar.gz"
  dest="${TMPDIR:-/tmp}/$(sanitize "$url")"

  if [ ! -e "$dest" ]; then
    mkdir -p "$dest"
    curl -fsSL "$url" | tar xz -C "$dest" --strip-components 1
  fi

  cd "$dest"
  shift 1
fi

if [ "$#" -gt 0 ]; then
  args=( "$@" )
elif [ -t 0 ]; then
  args=( bin lib libexec src )
else
  args=( )
fi

expanded_args=( )
for arg in "${args[@]}"; do
  if [ -d "$arg" ]; then
    IFS=$'\n'
    expanded_args=( "${expanded_args[@]}" $(find "$arg" -name '[^._]*' -type f) )
  elif [ -e "$arg" ]; then
    expanded_args[${#expanded_args}]="$arg"
  fi
done

if [ "${#expanded_args}" -eq 0 ] && [ -t 0 ]; then
  "$0" --help >&2
  exit 1
fi

{ cat "${expanded_args[@]}"
} | sed -E '
  /^[[:space:]]*$/d
  /^[[:space:]]*#/d
  /^__END__/q
' | wc -l
