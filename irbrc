#!/usr/bin/ruby
require 'irb/completion'
IRB.conf[:AUTO_INDENT] = true
require 'pp'
require 'rubygems'

# students.map_by_first_name
# require 'map_by_method'
# 6.to_article
#require 'to_activerecord' # warnings with Rails 2.0.2
# 'foo'.what?('FOO')
require 'what_methods'
# User.find(:all).map &its.contacts.map(&its.last_name.capitalize)
require 'methodphitamine'

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

# require 'wirble'
# Wirble.init
# Wirble.colorize

require 'irb/completion'

module Kernel
  private
    def r(arg)
      puts `fri "#{arg}"`
    end
end

class Object
  def puts_ri_documentation_for(obj, meth)
    case self
    when Module
      candidates = ancestors.map{|klass| "#{klass}::#{meth}"}
      candidates.concat(class << self; ancestors end.map{|k| "#{k}##{meth}"})
    else
      candidates = self.class.ancestors.map{|klass|  "#{klass}##{meth}"}
    end
    candidates.each do |candidate|
      #puts "TRYING #{candidate}"
      desc = `qri '#{candidate}'`
      unless desc.chomp == "nil"
      # uncomment to use ri (and some patience)
      #desc = `ri -T '#{candidate}' 2>/dev/null`
      #unless desc.empty?
        puts desc
        return true
      end
    end
    false
  end
  private :puts_ri_documentation_for

  def method_missing(meth, *args, &block)
    if md = /ri_(.*)/.match(meth.to_s)
      unless puts_ri_documentation_for(self,md[1])
        "Ri doesn't know about ##{meth}"
      end
    else
      super
    end
  end

  def ri_(meth)
    unless puts_ri_documentation_for(self,meth.to_s)
      "Ri doesn't know about ##{meth}"
    end
  end
end

RICompletionProc = proc{|input|
  bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
  case input
  when /(\s*(.*)\.ri_)(.*)/
    pre = $1
    receiver = $2
    meth = $3 ? /\A#{Regexp.quote($3)}/ : /./ #}
    begin
      candidates = eval("#{receiver}.methods", bind).map do |m|
        case m
        when /[A-Za-z_]/; m
        else # needs escaping
          %{"#{m}"}
        end
      end
      candidates = candidates.grep(meth)
      candidates.map{|s| pre + s }
    rescue Exception
      candidates = []
    end
  when /([A-Z]\w+)#(\w*)/ #}
    klass = $1
    meth = $2 ? /\A#{Regexp.quote($2)}/ : /./
    candidates = eval("#{klass}.instance_methods(false)", bind)
    candidates = candidates.grep(meth)
    candidates.map{|s| "'" + klass + '#' + s + "'"}
  else
    IRB::InputCompletor::CompletionProc.call(input)
  end
}
#Readline.basic_word_break_characters= " \t\n\"\\'`><=;|&{("
Readline.basic_word_break_characters= " \t\n\\><=;|&"
Readline.completion_proc = RICompletionProc
