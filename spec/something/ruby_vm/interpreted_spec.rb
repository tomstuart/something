require 'something/ruby_vm/interpreted'
require 'support/shared_examples'

RSpec.describe Something::RubyVM::Interpreted do
  include Something::RubyVM::Interpreted
  include Something::RubyVM::Interpreted::Translation

  it_should_behave_like 'an encoding of values and operations'
end
