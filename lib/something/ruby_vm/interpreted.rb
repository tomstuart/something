require 'something'
require 'something/evaluator'

module Something
  module RubyVM
    module Interpreted
      include Something::Evaluator

      class << (Apply = Object.new)
        def inspect = 'Apply'
      end
      Closure = Struct.new(:environment, :definition) do
        def inspect = "<#{environment.inspect}, #{definition.inspect}>"
      end

      def evaluate(expression)
        s, e, c, d = [], {}, [expression], nil

        loop do
          case { s: s, c: c, d: d }
          in c: [], d: nil, s: [result, *]
            return result
          in c: [], d: { s: s, e: e, c: c, d: d }, s: [result, *]
            s = [result] + s
          in c: [Variable(name), *c]
            s = [e.fetch(name)] + s
          in c: [Definition => definition, *c]
            s = [Closure.new(e, definition)] + s
          in c: [Closure | Constant => expression, *c]
            s = [expression] + s
          in c: [Apply, *c], s: [Closure(environment, Definition(parameter, body)), argument, *s]
            d = { s: s, e: e, c: c, d: d }
            s, e, c = [], environment.merge(parameter => argument), [body]
          in c: [Apply, *c], s: [receiver, argument, *s]
            s = [Call.new(receiver, argument)] + s
          in c: [Call(receiver, argument), *c]
            c = [argument, receiver, Apply] + c
          end
        end
      end
    end
  end
end
