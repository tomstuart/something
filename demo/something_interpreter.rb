$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'nothing'
require 'something/interpreter'
include Nothing
include Something::Interpreter
include Something::Interpreter::Translation

each_element(from_proc(FIZZBUZZ)) do |element|
  puts to_string(element)
end
