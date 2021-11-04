$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'nothing'
require 'something/ruby_vm/interpreted'
include Nothing
include Something::RubyVM::Interpreted
include Something::RubyVM::Interpreted::Translation

each_element(from_proc(FIZZBUZZ)) do |element|
  puts to_string(element)
end
