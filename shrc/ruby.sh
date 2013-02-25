if which noglob >/dev/null; then
  alias rake='noglob rake' # allows square brackets for rake task invocation
  alias brake='noglob bundle exec rake' # execute the bundled rake gem
fi

export RUBY_GC_MALLOC_LIMIT=60000000
export RUBY_FREE_MIN=200000

# console
function sc() {
  if [ -f config/environment.rb ] && which pry >/dev/null; then
    pry -r./config/environment.rb
  elif [ -x script/rails ]; then
    script/rails console
  elif [ -x script/console ]; then
    script/console
  elif [ -f app.rb ]; then
    local repl=$(which pry >/dev/null && echo pry || echo irb)
    local args=$([ -n "$BUNDLE_GEMFILE" -o -f Gemfile ] && echo "-rbundler/setup")
    $repl $args -I. -r./app.rb
  else
    echo "no script/rails or script/console found" >&2
    return 1
  fi
}

# server
function ss() {
  if [ -x script/rails ]; then
    script/rails server "$@"
  elif [ -x script/server ]; then
    script/server "$@"
  else
    echo "no script/rails or script/server found" >&2
    return 1
  fi
}

# restart
function sr() {
  mkdir -p tmp
  touch tmp/restart.txt
}
