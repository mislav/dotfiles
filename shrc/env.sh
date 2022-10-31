export HOMEBREW_NO_INSTALL_CLEANUP=true
export EDITOR=vim

if [ -d /usr/local/sbin ]; then
  export PATH=/usr/local/sbin:"$PATH"
fi

if type -p go >/dev/null; then
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

if [ -x ~/.rbenv/bin/rbenv ]; then
  PATH=~/.rbenv/bin:"$PATH"
fi
if type -p rbenv >/dev/null; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(rbenv init - --no-rehash zsh)"
  elif [ -n "$BASH" ]; then
    eval "$(rbenv init - --no-rehash bash)"
  fi
fi
if type -p rbenv >/dev/null || type -p ruby-build >/dev/null; then
  export RUBY_CONFIGURE_OPTS="--disable-install-doc"
  if openssl_dir="$(brew --prefix openssl@1.1 2>/dev/null)"; then
    export RUBY_CONFIGURE_OPTS="$RUBY_CONFIGURE_OPTS --with-openssl-dir=$openssl_dir"
  fi
  unset openssl_dir
fi

export PATH=~/bin:"$PATH"
export PATH="bin:$PATH"

if type -p direnv >/dev/null; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(direnv hook zsh)"
  elif [ -n "$BASH" ]; then
    eval "$(direnv hook bash)"
  fi
fi
