#######
# git #
#######
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

function superblame {
  git log --format=%h --author=$1 $2 | \
    xargs -L1 -ISHA git diff --shortstat 'SHA^..SHA' -- app config/environment* config/initializers/ public/stylesheets/ | \
    ruby -e 'n=Hash.new(0); while gets; i=0; puts $_.gsub(/\d+/){ n[i+=1] += $&.to_i }; end' | tail -n1
}

########
# RUBY #
########

if which noglob >/dev/null; then
  alias rake='noglob rake' # allows square brackets for rake task invocation
  alias brake='noglob bundle exec rake' # execute the bundled rake gem
fi

#########
# RAILS #
#########

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

# stop daemonized Rails server
function sst() {
  if [ -f tmp/pids/mongrel.pid ]; then
    echo "Stopping Mongrel ..."
    kill `cat tmp/pids/mongrel.pid`
  elif [ -f tmp/pids/server.pid ]; then
    echo "Stopping server ..."
    kill `cat tmp/pids/server.pid`
  fi
}

# restart Rails application
function sr() {
  if [ -f tmp/pids/mongrel.pid ]; then
    echo "Restarting Mongrel ..."
    kill -USR2 `cat tmp/pids/mongrel.pid`
  elif [ -f tmp/pids/server.pid ]; then
    echo "Restarting server ..."
    kill -USR2 `cat tmp/pids/server.pid`
  else
    echo "Restarting application ..."
    touch tmp/restart.txt
  fi
}

########
# misc #
########

alias h='history'
alias j="jobs -l"
alias l="ls -lah"
alias ll="ls -l"
alias la='ls -A'

# mojombo http://gist.github.com/180587
function psg {
  ps wwwaux | egrep "($1|%CPU)" | grep -v grep
}
