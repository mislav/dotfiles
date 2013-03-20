if [ -n "$ZSH_VERSION" ]; then
  [[ -z $AUTOBIN_LIST ]] && AUTOBIN_LIST=~/.config/autobin

  _autobin_hook() {
    if [[ -n $AUTOBIN_DIR ]]; then
      # remove old dir from path
      path=(${path:#$AUTOBIN_DIR})
      unset AUTOBIN_DIR
    fi
    if [[ -d "${PWD}/bin" ]] && grep "${PWD}/bin" "$AUTOBIN_LIST" >/dev/null 2>&1; then
      # add whitelisted dir to path
      AUTOBIN_DIR="${PWD}/bin"
      path=($AUTOBIN_DIR $path)
    fi
  }

  [[ -z $chpwd_functions ]] && chpwd_functions=()
  chpwd_functions=($chpwd_functions _autobin_hook)

  autobin() {
    local dir="${1:-$PWD}"
    [[ -d $dir/bin ]] && dir="${dir}/bin"
    if [[ -d $dir ]]; then
      grep "$dir" "$AUTOBIN_LIST" >/dev/null 2>&1 || echo "$dir" >> $AUTOBIN_LIST
      cd .
      hash -r 2>/dev/null || true
    else
      echo "invalid directory: $dir" >&2
      return 1
    fi
  }
fi
