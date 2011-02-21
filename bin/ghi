#!/usr/bin/env ruby -rubygems
# not sure who originally wrote this.
# got it from here: https://gist.github.com/251119
require "mutter"
require "httparty"

REMOTE = "origin"
REPO = `git config --get remote.#{REMOTE}.url`.chomp[/github\.com[\/\:]([^\/]+\/[^\/]+)\.git/, 1]
USER = `git config --get github.user`.chomp
TOKEN = `git config --get github.token`.chomp

class Issue
  include HTTParty
  base_uri "https://github.com/api/v2/json/issues"
  
  if USER.empty? or TOKEN.empty?
    default_params :output => 'json'
  else
    default_params :login => USER, :token => TOKEN, :output => 'json'
  end
  format :json

  def self.open(title)
    id = post("/open/#{REPO}", :query => { :title => title })["issue"]["number"]
    puts "Issue #{id} created."
  end
  
  def self.close(*ids)
    ids.each do |id|
      post("/close/#{REPO}/#{id}")
      puts "Issue #{id} closed."
    end
  end
  
  def self.reopen(*ids)
    ids.each do |id|
      post("/reopen/#{REPO}/#{id}")
      puts "Issue #{id} reopened."
    end
  end
  
  def self.view(id)
    system "open https://github.com/#{REPO}/issues/#{id}"
  end
  
  def self.browse
    system "open https://github.com/#{REPO}/issues"
  end
  
  def self.list(status="open")
    table = Mutter::Table.new do
      column :width => 3, :style => [:bold, :green], :align => :right
      column :style => :yellow
      column
    end
    
    data = get("/list/#{REPO}/#{status}")
    
    if data["issues"].empty?
      puts "No Issues"
    else
      data["issues"].each { |issue| table << issue.values_at("number", "user", "title") }
      puts table.to_s
    end
  end
end

case cmd = ARGV.shift
when /^\d+$/
  Issue.view cmd
when nil, "list"
  Issue.list
when "close", "c"
  Issue.close *ARGV
when "reopen"
  Issue.reopen *ARGV
when "browse", "b"
  Issue.browse
when "view", "v"
  Issue.view ARGV.first
when "help", "-h", "--help"
  abort <<-EOS
GitHub Issues power script

usage:
  
  List issues:      ghi
  Create an issue:  ghi "Your project sucks"
  View an issue:    ghi 7
  Close an issue:   ghi close 7  or  ghi c 7  or  ghi c 7 8 9
  Open browser:     ghi browse   or  ghi b

EOS
else
  Issue.open cmd
end
