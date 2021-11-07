require 'something/native_vm/compiled'
require 'support/shared_examples'

RSpec.describe Something::NativeVM::Compiled do
  include Something::NativeVM::Compiled
  include Something::NativeVM::Compiled::Translation

  it_should_behave_like 'an encoding of values and operations'
end
