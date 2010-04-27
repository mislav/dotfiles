#!/usr/bin/env ruby -wKU
$stdout.sync = true

for path in ARGV
  File.open(path, 'r') do |file|
    file.each_line { |line| puts line }
  end
end
