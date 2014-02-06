require 'pp'
require 'irb/completion'

IRB.conf[:PROMPT_MODE] = :SIMPLE

def pbcopy(data)
  File.popen('pbcopy', 'w') { |p| p << data.to_s }
  $?.success?
end
