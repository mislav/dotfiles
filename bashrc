# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

export EDITOR=vim

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null | \
    ruby -pe '$_.sub!(%r{^(?:refs/)?(?:(heads|tags)/)?(.+?)(\^0)?$}, %{ (\\2)})'
}

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h\[\033[00m\]:\[\e[0;31m\]\w\[\e[m\]$(parse_git_branch) $ '

# Terminal title (git completion is required for this):
# export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~} $(__git_ps1 " (%s)")"; echo -ne "\007"' 

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

homebrew=$(brew --prefix)

for file in $(find $homebrew/etc/bash_completion.d -not -type d)
do
  source $file 2>/dev/null
done

source $homebrew/Library/Contributions/brew_bash_completion.sh
