$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'nothing'
include Nothing
include Nothing::Translation

each_element(FIZZBUZZ) do |element|
  puts to_string(element)
end
