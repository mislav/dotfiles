[ -f ~/.bashrc ] && source ~/.bashrc

# setenv CLICOLOR "1"
# setenv LSCOLORS "ExFxCxDxBxegedabagacad"

localbin=/usr/local/bin

if [ -d $localbin ]; then
  export PATH=$localbin:$(echo $PATH | sed -E s%$localbin:?%%)
fi

if [ -L $localbin/ruby ]; then
  target=$(readlink $localbin/ruby)
  rubybin=$(cd $localbin/$(dirname $target) && pwd -P)
  export PATH=$rubybin:$PATH
fi

[ -d ~/.rbenv/bin ] && export PATH="$HOME/.rbenv/bin:$PATH"
[ -d ~/.coral/bin ] && export PATH=~/.coral/bin:$PATH
[ -d ~/bin ] && export PATH=~/bin:$PATH

eval "$(rbenv init -)"
