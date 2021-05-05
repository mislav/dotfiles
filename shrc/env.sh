export HOMEBREW_NO_INSTALL_CLEANUP=true
export EDITOR=vim

if type -p go >/dev/null; then
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

if [ -x ~/.rbenv/bin/rbenv ]; then
  PATH=~/.rbenv/bin:"$PATH"
  eval "$(~/.rbenv/bin/rbenv init -)"
fi

export PATH=~/.rbenv/versions/2.7.2/bin:~/.gem/ruby/2.7.0/bin:"$PATH"
export PATH=~/bin:"$PATH"
export PATH="bin:$PATH"

if type -p direnv >/dev/null; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(direnv hook zsh)"
  elif [ -n "$BASH" ]; then
    eval "$(direnv hook bash)"
  fi
fi
