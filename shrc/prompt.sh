# show git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
}

case $(basename "$SHELL") in

bash )
  # set variable identifying the chroot you work in (used in the prompt below)
  if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
  fi

  git_where() {
    ref="$(parse_git_branch)"
    echo ${ref#(refs/heads/|tags/)}
  }

  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h\[\033[00m\]:\[\e[0;31m\]\w\[\e[m\]$(git_where) $ '
  ;;

zsh )
  local GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
  local GIT_PROMPT_SUFFIX="]%{$reset_color%}"
  local GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
  local GIT_PROMPT_CLEAN=""

  # show red star if there are uncommitted changes
  parse_git_dirty() {
    if command git diff-index --quiet HEAD 2> /dev/null; then
      echo "$GIT_PROMPT_CLEAN"
    else
      echo "$GIT_PROMPT_DIRTY"
    fi
  }

  # if in a git repo, show dirty indicator + git branch
  git_custom_status() {
    local git_where="$(parse_git_branch)"
    [ -n "$git_where" ] && echo "$(parse_git_dirty)$GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
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
  ;;

esac
