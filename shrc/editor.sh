export EDITOR=vim
export GIT_EDITOR=$EDITOR

if [[ -z $TMUX ]]; then
  # wanted to set VISUAL here, but it affects too many things I don't want
  [[ "$(uname -s)" == Darwin ]] && GEM_EDITOR=mvim || GEM_EDITOR=gvim
  export GEM_EDITOR
fi
