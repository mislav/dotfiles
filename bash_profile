# vim:ft=sh:

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

export EDITOR=vim

if [[ $TERM =~ xterm ]]; then
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
fi

for file in ~/.shrc/*.sh; do
  source "$file"
done

[ -d ~/bin ] && export PATH=~/bin:"$PATH"
