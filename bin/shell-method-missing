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
  system(*cmd)
end

def echo(message)
  $stderr.puts("\n" + message)
end

case command.join(' ')
when /^git(@|:\/\/).*\.git$/
  # Clone any full git repo URL.
  # @example
  #   git://github.com/crafterm/jd.git
  #
  # TODO: Doesn't work with zsh. It never gets called.
  # TODO: Take a second argument for the destination name.
  
  run("git", "clone", command)
  
when /^(.*) (.*)\.git$/
  # Clone a user and project from GitHub.
  # Does the right thing when cloning your own projects.
  #
  # @example
  #   bjeanes dot-files.git
  git_project_user      = $1
  git_project_name      = $2
  destination_directory = ""
  git_url               = ""
  
  if git_project_user == ENV['USER']
    destination_directory = git_project_name
    git_url = "git@github.com:#{git_project_user}/#{git_project_name}.git"
  else
    destination_directory = [git_project_user, git_project_name].join('-')
    git_url = "git://github.com/#{git_project_user}/#{git_project_name}.git"
  end
  # TODO: Would be nice to cd to the project directory afterwards
  run "git", "clone", git_url, destination_directory
  echo "Cloned as \'#{destination_directory}\'"
  
when /^(?:ftp|https?):\/\/.+\.t(?:ar\.)?gz$/
  # Download and unzip a URL
  run "curl #{command} | tar xzv"
  
when /^[a-z0-9_\-\/]+\.feature$/
  run "cucumber", command
  
when /^[A-Za-z0-9_\-\/]+\.gem$/
  # Install a gem
  # @example
  #   haml.gem
  gem_to_install = command.first.gsub(/\.gem$/, '')
  run "sudo", "gem", "install", gem_to_install
  
else
  abort "Error: No matching action defined in #{__FILE__.inspect}"
end

# Other Ideas:
# * Open URL in browser
# * cd to a path
# * Run a spec by name
# * Run a rake task by name

