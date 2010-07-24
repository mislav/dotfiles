#!/usr/bin/env ruby
## Convert Windows to Unix line breaks
#
# Author:  Mislav Marohnić  <mislav.marohnic@gmail.com>

ARGV.each do |file|
  next unless file =~ /\.\w{2,4}$/
  text = File.read(file)
  if text[0,3] == "\357\273\277" or text.index("\r\n")
    File.open(file, 'w') { |f| f << text.sub("\357\273\277", '').gsub("\r\n", "\n") }
    puts "#{file} cleansed."
  end
end