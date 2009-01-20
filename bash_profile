export PATH=~/bin:$PATH

export PATH=$PATH:/opt/local/bin
export MANPATH=$MANPATH:/opt/local/share/man
export INFOPATH=$INFOPATH:/opt/local/share/info

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

setenv CLICOLOR "1"
setenv LSCOLORS "ExFxCxDxBxegedabagacad"