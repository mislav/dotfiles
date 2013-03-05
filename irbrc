# http://linux.die.net/man/1/irb
require 'irb/completion'
# IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE
require 'pp'

if $0 == 'irb' && ENV['RAILS_ENV']
  def l(stream = STDOUT)
    ActiveRecord::Base.logger = Logger.new(stream)
    if Rails::VERSION::MAJOR >= 2 and Rails::VERSION::MINOR >= 2
      ActiveRecord::Base.connection_pool.clear_reloadable_connections!
    else
      ActiveRecord::Base.clear_active_connections!
    end
    "logger reset!"
  end
end

# def time(times = 1)
#   ret = nil
#   Benchmark.bm { |x| x.report { times.times { ret = yield } } }
#   ret
# end

def copy(data)
  File.popen('pbcopy', 'w') { |p| p << data.to_s }
  $?.success?
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
