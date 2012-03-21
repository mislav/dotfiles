## Mislav's zsh config
#
# Features: tab-completion, colors, Homebrew, rbenv, nifty prompt
#
# Uses very few oh-my-zsh scripts, but works without them too.


# oh-my-zsh checkout
ZSH=$HOME/.oh-my-zsh

# use case-sensitive completion
# CASE_SENSITIVE="true"

# if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"


## PATH tweaks ##


(){
local brewbin=/usr/local/bin
if [ -d $brewbin ]; then
  local brewprefix=$(dirname $brewbin)
  export PATH=$brewprefix/sbin:"$PATH"
  export PATH=$brewbin:"$(echo $PATH | sed -E "s%$brewbin:?%%")"
fi
}

if [ -d $HOME/.rbenv/bin ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

[ -d ~/.coral/bin ] && export PATH=~/.coral/bin:"$PATH"
[ -d ~/bin ] && export PATH=~/bin:"$PATH"


## load few oh-my-zsh scripts ##


if [ -d $ZSH ]; then
  (){
  local config_file plugin

  for config_file (completion history); do
    source $ZSH/lib/$config_file.zsh
  done

  for plugin (heroku gem bundler brew); do
    fpath=($ZSH/plugins/$plugin $fpath)
  done
  }
fi

# Load and run compinit
autoload -U compinit
compinit -i


## misc customization ##


export EDITOR=vim

# C-x C-e to edit command-line in EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

[ -f ~/.bash_aliases ] && source ~/.bash_aliases

autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
# setopt auto_cd
# setopt multios
# setopt cdablevarS
setopt prompt_subst

# Find the option for using colors in ls, depending on the version: Linux or BSD
ls --color -d . &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'

export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

if which hub >/dev/null; then
  eval "$(hub alias -s)"
fi

## shell prompt ##


ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# show git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
}

# show red star if there are uncommitted changes
parse_git_dirty() {
  if git diff-index --quiet HEAD 2> /dev/null; then
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  else
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  fi
}

# if in a git repo, show dirty indicator + git branch
git_custom_status() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# show current rbenv version if different from rbenv global
rbenv_version_status() {
  local ver=$(rbenv version-name)
  [ "$(rbenv global)" != "$ver" ] && echo "[$ver]"
}

# put fancy stuff on the right
if which rbenv &> /dev/null; then
  RPS1='$(git_custom_status)%{$fg[red]%}$(rbenv_version_status)%{$reset_color%} $EPS1'
else
  RPS1='$(git_custom_status) $EPS1'
fi

# basic prompt on the left
PROMPT='%{$fg[cyan]%}%~% %(?.%{$fg[green]%}.%{$fg[red]%})%B$%b '
