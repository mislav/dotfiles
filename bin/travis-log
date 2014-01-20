#!/usr/bin/env bash
# vim:ft=ruby:
exec /usr/bin/env ruby --disable-gems -x "$0" "$@"
#!ruby
# encoding: utf-8

require 'json'
require 'open-uri'
require 'fileutils'

in_color = ARGV.detect {|a| a =~ /^--(no-)?color$/ } ? !$1 : $stdout.tty?

fold = ->(string) {
  string.gsub(/travis_fold:start:.+?\r.*?travis_fold:end:.+?\r/m, '')
}

colorized = ->(string) {
  string.encode('utf-8').
    gsub(/\r {10,}\r+/, "\r\n").
    gsub(/[^[:print:]\e\n]/, '')
}

clean = ->(string) {
  colorized.(string).gsub(/\e[^m]+m/, '')
}

branch = `git rev-parse --symbolic-full-name @{u} 2>/dev/null`.chomp.sub(%r{^refs/remotes/.+?/}, '')
branch = `git symbolic-ref -q HEAD`.chomp.sub(%r{^refs/heads/}, '') unless $?.success?
repo   = `git config remote.origin.url`.chomp.match(%r{github\.com/(.+?/[^/]+)})[1].sub(/\.git$/, '')
sha    = `git rev-parse -q HEAD @{u} 2>/dev/null | tail -1`.chomp
cache  = "tmp/travis-log/#{sha}"

if File.exist?(cache)
  logs = File.read(cache)
else
  data = JSON.parse(open("https://api.travis-ci.org/repos/#{repo}/branches/#{branch}").read)
  job_ids = data['branch']['job_ids']
  job_sha = data['commit']['sha']

  abort "aborted: latest commit tested by Travis doesn't match current" if job_sha != sha

  logs = job_ids.map { |job|
    begin
      open("http://s3.amazonaws.com/archive.travis-ci.org/jobs/#{job}/log.txt").read
    rescue OpenURI::HTTPError
      abort "Error fetching log for job ##{job}; maybe the build hasn't completed yet?"
    end
  }.join("\n\n")

  FileUtils.mkdir_p(File.dirname(cache))
  File.open(cache, 'w') {|c| c << logs }
end

if in_color
  puts colorized.(fold.(logs))
else
  puts clean.(fold.(logs))
end
