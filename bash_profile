export PATH=$PATH:/opt/local/bin
export MANPATH=$MANPATH:/opt/local/share/man
export INFOPATH=$INFOPATH:/opt/local/share/info

export PATH=/usr/local/mysql/bin:$PATH
export PATH=/Library/PostgreSQL/8.3/bin:$PATH
export PATH=~/bin:$PATH

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

setenv CLICOLOR "1"
setenv LSCOLORS "ExFxCxDxBxegedabagacad"