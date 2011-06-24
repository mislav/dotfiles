#!/usr/bin/env ruby

# DESCRIPTION: Tries to do something with unrecognized shell input.
#              See the case statement for descriptions and examples.
#
# AUTHOR:      Bodaniel Jeanes
#              http://github.com/bjeanes/dot-files
#
# MODIFIED:    Geoffrey Grosenbach
#              http://peepcode.com
#
# INSTALL:
#              zsh:
#                   function command_not_found_handler() {
#                     ~/bin/shell_method_missing $*
#                   }

# Use all arguments
command = ARGV

# Prints and runs a command.
#
# @param [String, Array] cmd Command to run.
#   Automatically joins Arrays with &&.

def run(*cmd)
  $stderr.puts "Running '#{cmd.join(' ')}' instead"
  exec(*cmd)
end

case command.join(' ')
when /^\w+=/
  # bash variable assignment; ignore it
when /^git(@|:\/\/).*\.git$/
  # Clone any full git repo URL.
  # @example
  #   git://github.com/crafterm/jd.git
  #
  # TODO: Doesn't work with zsh. It never gets called.
  # TODO: Take a second argument for the destination name.
  
  run("git", "clone", command)
  
when /^(?:ftp|https?):\/\/.+\.t(?:ar\.)?gz$/
  # Download and unzip a URL
  run "wget #{command.first} -O- | tar xzv"
  
when /^[A-Za-z0-9_\-\/]+\.gem$/
  # Install a gem
  # @example
  #   haml.gem
  name = command.first.gsub(/\.gem$/, '')
  run "gem", "install", name
  
else
  binfile = File.expand_path(command.first) rescue nil
  unless binfile.nil? or File.exist? binfile
    warn "Error: No matching action for #{command.inspect} defined in #{__FILE__.inspect}"
  end
end
