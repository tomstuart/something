require 'something/ruby_vm/compiled'
require 'support/shared_examples'

RSpec.describe Something::RubyVM::Compiled do
  include Something::RubyVM::Compiled
  include Something::RubyVM::Compiled::Translation

  it_should_behave_like 'an encoding of values and operations'
end
