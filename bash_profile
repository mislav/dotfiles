# vim:ft=sh:
if [ -r ~/.profile ]; then
  source ~/.profile
fi

export CLICOLOR=1
export HISTCONTROL=ignoredups
export EDITOR=vim

PATH=/usr/local/bin:"$PATH"
PATH=~/.rbenv/bin:"$PATH"
eval "$(rbenv init -)"
PATH=~/bin:"$PATH"
PATH=bin:"$PATH"
export PATH="$(consolidate-path "$PATH")"

bash_completion="$(brew --prefix 2>/dev/null)/etc/bash_completion"
if [ -r "$bash_completion" ]; then
  source "$bash_completion"
fi
unset bash_completion

_git_prompt() {
  local ref="$(command git symbolic-ref -q HEAD 2>/dev/null)"
  echo "${ref:+ (${ref#refs/heads/})}"
}

_failed_status() {
  [ "$PIPESTATUS" -ne 0 ] && printf "$"
}

_success_status() {
  [ "$PIPESTATUS" -eq 0 ] && printf "$"
}

PS1='\[\e[0;31m\]\w\[\e[m\]$(_git_prompt) \[\e[1;31m\]$(_failed_status)\[\e[m\]$(_success_status) '

# Allow <C-s> to pass through to shell and programs
stty -ixon -ixoff
