brew=/usr/local

if [ -x $brew/bin/brew ]; then
  PATH=$brew/sbin:"$PATH"
  PATH=$brew/bin:"$(echo $PATH | sed -E "s%$brew/bin:?%%")"
  export PATH

  if [[ -n $BASH ]]; then
    for file in $brew/etc/bash_completion.d/*; do
      [ -f "$file" ] && source "$file" 2>/dev/null
    done

    source $brew/Library/Contributions/brew_bash_completion.sh
  fi
fi

unset brew file
