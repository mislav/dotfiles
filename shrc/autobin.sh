if [[ -n $ZSH_VERSION ]]; then
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
fi
