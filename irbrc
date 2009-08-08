#!/usr/bin/ruby
require 'irb/completion'
# IRB.conf[:AUTO_INDENT] = true
require 'pp'
require 'rubygems'

# students.map_by_first_name
# require 'map_by_method'
# 6.to_article
# require 'to_activerecord' # warnings with Rails 2.0.2
# 'foo'.what?('FOO')
# require 'what_methods'
# User.find(:all).map &its.contacts.map(&its.last_name.capitalize)
# require 'methodphitamine'

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']

def time(times = 1)
  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end

if defined? Benchmark
  class Benchmark::ReportProxy
    def initialize(bm, iterations)
      @bm = bm
      @iterations = iterations
      @queue = []
    end
    
    def method_missing(method, *args, &block)
      args.unshift(method.to_s + ':')
      @bm.report(*args) do
        @iterations.times { block.call }
      end
    end
  end

  def compare(times = 1, label_width = 12)
    Benchmark.bm(label_width) do |x|
      yield Benchmark::ReportProxy.new(x, times)
    end
  end
end

