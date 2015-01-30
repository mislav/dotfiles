#!/usr/bin/env zsh
# Remove duplicate entries from PATH

typeset -a paths result
IFS=: paths=($1)

while [[ ${#paths} -gt 0 ]]; do
  p="${paths[1]}"
  shift paths
  [[ -z ${paths[(r)$p]} ]] && result+="$p"
done

echo ${(j+:+)result}
