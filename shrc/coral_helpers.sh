# Open a project in editor.
# Usage: dive <project> [<editor args>..]
#
# The project name is first searched in Coral repos, then in current
# gem bundle, then in RubyGems.
#
# If no extra arguments are given, it will try to open the project's
# README file by default.
dive() {
  local dir="$(coral path "$1" 2>/dev/null || coral gem-dir "$1")"
  [[ -n $dir ]] || return 1
  shift 1

  # refresh tags
  ( cd "$dir"
    if [[ -d .git ]]; then
      ctags -R --languages=ruby --exclude=.git --tag-relative -f.git/tags
    else
      ctags -R --languages=ruby
    fi
  )

  local editor=${VISUAL:-$EDITOR}
  editor=${GEM_EDITOR:-$editor}

  if [[ $# -gt 0 ]]; then
    # open with arguments to editor
    EDITOR="$editor" coral open-dir "$dir" "$@"
  else
    local readme="$(coral find-readme "$dir" | head -1)"
    if [[ -n $readme ]]; then
      # open the readme initially
      EDITOR="$editor" coral open-dir "$dir" "$readme"
    else
      EDITOR="$editor" coral open-dir "$dir"
    fi
  fi
}
