# Some useful aliases
# vi:filetype=sh:
alias aliases='vim ~/.bash_aliases && source ~/.bash_aliases'

# Function which adds an alias to the current shell and to
# the ~/.bash_aliases file.
add-alias ()
{
   local name=$1 value="$2"
   echo "alias $name='$value'" >> ~/.bash_aliases
   eval "alias $name='$value'"
   alias $name
}

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
  if [ -z "$1" ]; then
    git checkout master
  else
    git checkout $1
  fi
}

function superblame {
  git log --format=%h --author=$1 $2 | \
    xargs -L1 -ISHA git diff --shortstat 'SHA^..SHA' app config/environment* config/initializers/ public/stylesheets/ | \
    ruby -e 'n=Hash.new(0); while gets; i=0; puts $_.gsub(/\d+/){ n[i+=1] += $&.to_i }; end' | tail -n1
}

########
# RUBY #
########
# really awesome function, use: cdgem <gem name>, cd's into your gems directory
# and opens gem that best matches the gem name provided
function cdgem {
  cd `gem env gemdir`/gems
  cd `ls | grep $1 | sort | tail -1`
}
function gemdoc {
  GEMDIR=`gem env gemdir`/doc
  open $GEMDIR/`ls $GEMDIR | grep $1 | sort | tail -1`/rdoc/index.html
}
function mategem {
  gemdir=$(gem env gemdir)/gems
  name=$(ls $gemdir | ruby -r rubygems/version -e 'gem = STDIN.lines.
      map {|l| l =~ /-([^-]+)\s*$/; [$`, Gem::Version.new($1)] if $` == ARGV.first }.
      compact.sort_by(&:last).last
    print gem.join("-") if gem
    ' $1)

  if [ -z "$name" ]; then
    echo "gem not found" 1>&2
  else
    $EDITOR $gemdir/$name
  fi
}

function r19 {
  switch-ruby $(brew --prefix)/Cellar/ruby/1.9.2-p180/bin
}

function r18 {
  switch-ruby $(brew --prefix)/Cellar/ruby-enterprise-edition/2011.02/bin
}

function r186 {
  switch-ruby /opt/ruby1.8.6/bin
}

function switch-ruby {
  echo "using $1"
  export PATH=$(ruby -e 'puts ENV["PATH"].split(":").map { |p| p =~ /\bruby[^a-z]/i ? ARGV[0] : p }.uniq.join(":")' $1)
}

#########
# RAILS #
#########

# console
function sc() {
  if [ -f config/environment.rb ] && which -s pry; then
    pry -r./config/environment.rb
  elif [ -x script/rails ]; then
    script/rails console
  elif [ -x script/console ]; then
    script/console
  else
    echo "no script/rails or script/console found" >&2
  fi
}

# server
function ss() {
  if [ -x script/rails ]; then
    script/rails server
  elif [ -x script/server ]; then
    script/server
  else
    echo "no script/rails or script/server found" >&2
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
    echo "Restarting Passenger instances ..."
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
# alias pu="pushd"
# alias po="popd"

# mojombo http://gist.github.com/180587
function psg {
  ps wwwaux | egrep "($1|%CPU)" | grep -v grep
}

#
# Csh compatability:
#
alias unsetenv=unset
function setenv () {
  export $1="$2"
}
