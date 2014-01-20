#!/usr/bin/ruby --disable-gems -n
# Annotates each line of input with the number of milliseconds elapsed since
# the last line. Useful for figuring out slow points of output-producing programs.

BEGIN {
  $last = $start = Time.now
}

now = Time.now
delta = now - $last
$last = now

printf '%5.2f ', delta * 1000
puts $_

END {
  delta = $last - $start
  printf "%5.2f ms total\n", delta * 1000
}
