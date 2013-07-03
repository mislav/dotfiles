alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gb='git branch -v'
alias st='git status -sb'

function gco {
  if [ $# -eq 0 ]; then
    git checkout master
  else
    git checkout "$@"
  fi
}

if [ -n "$ZSH_VERSION" ]; then
  compdef _git gc=git-commit
  compdef _git gca=git-commit
  compdef _git gco=git-checkout
  compdef _git gb=git-branch
  compdef _git st=git-status
  compdef _git gl=git-pull
  compdef _git gp=git-push
  compdef _git gd=git-diff
fi

# TODO: install git hook to prevent pushing commits with "TODO:"
function todo {
  git commit --allow-empty -m "TODO: $*"
}
