# vim:ft=sh:sw=2:ts=2:et
if [ -r ~/.profile ]; then
  source ~/.profile
fi

HISTCONTROL=ignoredups

HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null)"
if [ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]; then
  source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
else
  for HOMEBREW_COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
    [ -r "$HOMEBREW_COMPLETION" ] && source "$HOMEBREW_COMPLETION"
  done
fi
unset HOMEBREW_PREFIX
unset HOMEBREW_COMPLETION

# Allow <C-s> to pass through to shell and programs
stty -ixon -ixoff

for file in ~/.shrc/*.sh; do
  source "$file"
done
