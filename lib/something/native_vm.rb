require 'ffi'
require 'something'
require 'something/evaluator'

module Something
  module NativeVM
    include Something::Evaluator

    def variable(name)
      expression.tap do |expression|
        expression[:type] = :variable
        data = expression[:data][:variable]
        data[:name] = FFI::MemoryPointer.from_string(name.to_s)
      end
    end

    def call(receiver, argument)
      expression.tap do |expression|
        expression[:type] = :call
        data = expression[:data][:call]
        data[:receiver] = receiver
        data[:argument] = argument
      end
    end

    def definition(parameter, body)
      expression.tap do |expression|
        expression[:type] = :definition
        data = expression[:data][:definition]
        data[:parameter] = FFI::MemoryPointer.from_string(parameter.to_s)
        data[:body] = body
      end
    end

    def constant(name)
      expression.tap do |expression|
        expression[:type] = :constant
        data = expression[:data][:constant]
        data[:name] = FFI::MemoryPointer.from_string(name.to_s)
      end
    end

    module Translation
      include Something::Evaluator::Translation

      def to_c(expression)
        case expression
        in Something::Variable(name)
          variable(name)
        in Something::Call(receiver, argument)
          call(to_c(receiver), to_c(argument))
        in Something::Definition(parameter, body)
          definition(parameter, to_c(body))
        in Something::Evaluator::Constant(name)
          constant(name)
        end
      end

      def from_c(expression)
        case expression[:type]
        in :variable
          data = expression[:data][:variable]
          name = data[:name]
          Something::Variable.new(name)
        in :call
          data = expression[:data][:call]
          receiver, argument = data[:receiver], data[:argument]
          Something::Call.new(from_c(receiver), from_c(argument))
        in :definition
          data = expression[:data][:definition]
          parameter, body = data[:parameter], data[:body]
          Something::Definition.new(parameter, from_c(body))
        in :constant
          data = expression[:data][:constant]
          name = data[:name]
          Something::Evaluator::Constant.new(name)
        end
      end

      def from_proc(p) = to_c(Something::Translation.from_proc(p))

      def identify_integer(*args) = super(*args.map { |e| from_c(e) })

      def identify_boolean(*args) = super(*args.map { |e| from_c(e) })
    end
  end
end
