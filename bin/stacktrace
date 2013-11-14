#!/usr/bin/env bash
# Usage: stacktrace <logfiles>
#
# Extract the last Ruby-like stack trace from log file(s).
set -e

reverse() {
  sed -n '1!G;h;$p'
}

tail -1000 "$@" | reverse | \
  sed -E '
    /:[[:digit:]]+:in / !{
      # blank out lines that dont look like stack trace
      s/.+//
    }
    # un-indent
    s/^ +(.+)$/\1/
  ' | sed -En '
    /^.+/,$ {
      # extract only the first "island" of non-blank lines
      /^$/q
      p
    }
  ' | reverse
