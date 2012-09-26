npmbinpath="$(npm bin -g 2>/dev/null)"

if [[ -n $npmbinpath ]]; then
  export PATH="$npmbinpath:$PATH"
fi

unset npmbinpath
