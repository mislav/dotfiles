#!/usr/bin/env ruby
# for each git repo in a subdirectory ...
dirs = Dir['**/.git'].map { |gd| File.dirname(gd) }

def prompt
  print ">> "
  gets
end

# ... execute a command given on STDIN
while command = prompt
  dirs.each do |dir|
    begin
      Dir.chdir(dir) do
        puts "~ #{dir}:"
        system command
      end
    rescue Errno::ENOENT => e
      $stderr.puts e.message
    end
  end
end

# (press Ctrl+D to break out of the loop)