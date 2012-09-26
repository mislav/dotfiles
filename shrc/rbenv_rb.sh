# Shortcut interface to rbenv to quickly pick & switch between Ruby versions.
# Usage:
#   rb <version> [19]
#   rb <version> [19] <command>...
#   rb
#
# A version specifier can be a partial string which will be matched against
# available versions and the last match will be picked. The optional "19"
# argument switches JRuby or Rubinius to 1.9 mode.
#
# When no arguments are given, the current ruby version in the shell is reset
# to default.
#
# Examples:
#   rb 1.8
#   rb ree
#   rb rbx irb
#   rb rbx 19 ruby -v
#   rb jr 19 rake something
#
rb() {
  if [[ $# -lt 1 ]]; then
    rbenv shell --unset
    # warning: potentially destructive to user's environment
    unset RBXOPT
    unset JRUBY_OPTS
  else
    local ver="$(rbenv versions --bare | grep "$1" | tail -1)"
    if [[ -z $ver ]]; then
      echo "no ruby version match found" >&2
      return 1
    else
      shift
      if [[ $1 == 19 ]]; then
        local rbx_opt="RBXOPT=-X19"
        local jrb_opt="JRUBY_OPTS=--1.9"
        shift
      fi

      if [[ $# -gt 0 ]]; then
        env RBENV_VERSION="$ver" $rbx_opt $jrb_opt "$@"
      else
        [[ -n $rbx_opt || -n $jrb_opt ]] && export $rbx_opt $jrb_opt
        rbenv shell "$ver"
      fi
    fi
  fi
}
