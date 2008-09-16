export MAGICK_HOME=/usr/local/ImageMagick
export DYLD_LIBRARY_PATH=$MAGICK_HOME/lib
export PATH=$MAGICK_HOME/bin:$PATH

export GEM_HOME=/Users/mislav/.gems
export PATH=$GEM_HOME/bin:$PATH
export PATH=/usr/local/git/bin:$PATH
export PATH=/usr/local/mysql/bin:$PATH
export PATH=~/bin:$PATH

export MANPATH=/usr/local/git/man:$MANPATH

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

export CLICOLOR="1"
export LSCOLORS="ExFxCxDxBxegedabagacad"
