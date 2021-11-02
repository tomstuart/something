require 'nothing'
require 'something'
require 'something/evaluator'

module Something
  module Interpreter
    include Something::Evaluator

    def evaluate(expression)
      loop do
        expression = reduce(expression)
      rescue NoMatchingPatternError
        return expression
      end
    end

    private

    def reduce(expression)
      case expression
      in Call(receiver, argument) unless value?(receiver)
        Call.new(reduce(receiver), argument)
      in Call(receiver, argument) unless value?(argument)
        Call.new(receiver, reduce(argument))
      in Call(Definition(parameter, body), argument)
        replace(parameter, argument, body)
      end
    end

    def value?(expression)
      case expression
      in Definition | Constant
        true
      in Call(Constant, argument) if value?(argument)
        true
      else
        false
      end
    end

    def replace(name, replacement, original)
      case original
      in Variable(^name)
        replacement
      in Variable
        original
      in Call
        Call.new(
          replace(name, replacement, original.receiver),
          replace(name, replacement, original.argument)
        )
      in Definition(^name, _)
        original
      in Definition
        Definition.new(
          original.parameter,
          replace(name, replacement, original.body)
        )
      in Constant
        original
      end
    end
  end
end
