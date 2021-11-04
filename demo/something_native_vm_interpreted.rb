$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'nothing'
require 'something/native_vm/interpreted'
include Nothing
include Something::NativeVM::Interpreted
include Something::NativeVM::Interpreted::Translation

each_element(from_proc(FIZZBUZZ)) do |element|
  puts to_string(element)
end
