export EDITOR=vim
export GIT_EDITOR=$EDITOR
# wanted to set VISUAL here, but it affects too many things I don't want
[[ "$(uname -s)" == Darwin ]] && GEM_EDITOR=mvim || GEM_EDITOR=gvim
export GEM_EDITOR

if which zle >/dev/null; then
  # C-x C-e to edit command-line in EDITOR
  autoload -U edit-command-line
  zle -N edit-command-line
  bindkey '\C-x\C-e' edit-command-line
fi
