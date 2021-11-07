$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'nothing'
require 'something/native_vm/compiled'
include Nothing
include Something::NativeVM::Compiled
include Something::NativeVM::Compiled::Translation

each_element(from_proc(FIZZBUZZ)) do |element|
  puts to_string(element)
end
