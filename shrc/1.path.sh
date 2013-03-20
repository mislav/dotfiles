if [ -n "$ZSH_VERSION" ]; then
  if [ "${(k)path[(r)/usr/bin]}" -lt "${(k)path[(r)/usr/local/bin]}" ]; then
    path=(${path#/usr/local/bin})
  fi
fi

PATH="/usr/local/sbin:$PATH"
PATH="/usr/local/bin:$PATH"
PATH="/usr/local/share/npm/bin:$PATH"
PATH="/usr/local/share/python:$PATH"

PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

coral="$(ls -d "$HOME/Projects/coral/bin/coral" \
               "$HOME/.coral/bin/coral" \
                2>/dev/null | head -1
        )"

[ -n "$coral" ] && eval "$("$coral" init -)"
unset coral

eval "$(hub alias -s)"

PATH="$HOME/.gem/global/bin:$PATH"
PATH="$HOME/bin:$PATH"

export PATH
export PATH="$(consolidate-path)"
