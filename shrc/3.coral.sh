if [ -x ~/Projects/coral/bin/coral ]; then
  eval "$(~/Projects/coral/bin/coral init -)"
elif [ -x ~/.coral/bin/coral ]; then
  eval "$(~/.coral/bin/coral init -)"
fi
