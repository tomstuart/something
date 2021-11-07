$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'nothing'
require 'something/ruby_vm/compiled'
include Nothing
include Something::RubyVM::Compiled
include Something::RubyVM::Compiled::Translation

each_element(from_proc(FIZZBUZZ)) do |element|
  puts to_string(element)
end
