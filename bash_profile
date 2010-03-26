[ -f ~/.bashrc ] && source ~/.bashrc

setenv CLICOLOR "1"
setenv LSCOLORS "ExFxCxDxBxegedabagacad"

HOMEBREW=/opt/local
REE=$HOMEBREW/Cellar/ruby-enterprise-edition/2009.10

if [ -d $HOMEBREW ]; then
  [ -d $REE ] && export PATH=$REE/bin:$PATH
  export PATH=$HOMEBREW/bin:$PATH
fi

[ -d ~/bin ] && export PATH=~/bin:$PATH
