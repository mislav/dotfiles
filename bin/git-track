#!/usr/bin/env ruby -w
current_branch = File.read('.git/HEAD').chomp.split(' refs/heads/').last
track = ARGV.first

if track and track.index('/')
  remote, branch = track.split('/', 2)
else
  remote = track || 'origin'
  branch = current_branch
end
    
system %(git config branch.#{current_branch}.remote #{remote})
system %(git config branch.#{current_branch}.merge refs/heads/#{branch})

puts "tracking #{remote}/#{branch}"
