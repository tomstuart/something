require 'something/native_vm/interpreted'
require 'support/shared_examples'

RSpec.describe Something::NativeVM::Interpreted do
  include Something::NativeVM::Interpreted
  include Something::NativeVM::Interpreted::Translation

  it_should_behave_like 'an encoding of values and operations'
end
