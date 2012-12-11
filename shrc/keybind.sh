if [[ -n $ZSH_VERSION ]]; then
  # Select "emacs" keymap.
  # This enables:
  # - Ctrl-a: beginning of line
  # - Ctrl-e: end of line
  # - Ctrl-r: incremental history search backward
  # - Ctrl-s: incremental history search forward
  #
  # This is necessary because if the EDITOR environment variable
  # contains "vi" then the default keymap would be "viins" which
  # doesn't map all these goodies by default.
  #
  # See `man zshzle`
  bindkey -e
fi
