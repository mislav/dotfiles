# vi:ts=2:sw=2:et:

# show git branch/tag, or name-rev if on detached head
_git_symbolic_ref() {
  command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD
}

if [[ -n $BASH ]]; then
  _git_where() {
    local ref="$(_git_symbolic_ref 2>/dev/null)"
    ref="${ref#refs/heads/}"
    [ -z "$ref" ] || printf ' (%s)' "$ref"
  }

  PS1='\[\033[01;32m\]\h\[\033[00m\]:\[\e[0;31m\]\w\[\e[m\]$(_git_where) $ '

elif [[ -n $ZSH_VERSION ]]; then
  setopt prompt_subst

  local GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
  local GIT_PROMPT_SUFFIX="]%{$reset_color%}"

  _git_where() {
    local ref="$(_git_symbolic_ref 2>/dev/null)"
    ref="${ref#refs/heads/}"
    [ -z "$ref" ] || printf ' %s%s%s' "$GIT_PROMPT_PREFIX" "$ref" "$GIT_PROMPT_SUFFIX"
  }

  PROMPT=$'\n''%{$fg[cyan]%}%~%{$reset_color%}$(_git_where) $ '

fi
