require 'nothing'
require 'support/shared_examples'

RSpec.describe Nothing do
  include Nothing::Translation

  # dummy implementations to support shared examples
  def from_proc(p) = p
  def call(receiver, argument) = receiver[argument]

  it_should_behave_like 'an encoding of values and operations'
end
