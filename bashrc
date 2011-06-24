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
  (git symbolic-ref -q HEAD || git name-rev --name-only HEAD) 2>/dev/null | sed -E 's:(refs/)?(heads|tags)/(.+): (\3):'
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

if [ -f ~/bin/sake-completion ]; then
  complete -C ~/bin/sake-completion -o default sake
fi

git_completion='/opt/local/etc/bash_completion.d/git-completion.bash'

if [ -f $git_completion ]; then
  source $git_completion
fi

# Method missing for bash. Add to your .bashrc
trap 'if ! type -t $BASH_COMMAND >/dev/null; then ~/bin/shell-method-missing $BASH_COMMAND; fi' DEBUG
