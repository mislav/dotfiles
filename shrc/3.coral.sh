if [ -d ~/.coral/bin ]; then
 export PATH=~/.coral/bin:"$PATH"

  # Provide `coral cd <name>` command, which uses `coral path <name>` and changes
  # into the resulting directory.
  function coral {
    if [[ $1 = 'cd' ]]; then
      shift
      local dir
      dir="$(command coral path "$@")" || return $?
      cd "$dir"
    else
      command coral "$@"
    fi
  }
fi
