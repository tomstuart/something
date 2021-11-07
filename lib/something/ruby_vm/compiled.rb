require 'something'
require 'something/evaluator'

module Something
  module RubyVM
    module Compiled
      include Something::Evaluator

      Closure = Struct.new(:environment, :parameter, :control) do
        def inspect = "<#{environment.inspect}, -> #{parameter} { #{control.inspect} }>"
      end

      def evaluate(expression)
        execute(compile(expression))
      end

      private

      def compile(expression)
        case expression
        in Variable(name)
          [[:variable, name]]
        in Call(receiver, argument)
          [[:apply]].concat(compile(receiver), compile(argument))
        in Definition(parameter, body)
          [[:definition, parameter, [[:return]].concat(compile(body))]]
        in Constant(name)
          [[:constant, name]]
        in Closure(environment, parameter, control)
          [[:closure, environment, parameter, control]]
        end
      end

      def execute(c)
        s, e = [], {}

        loop do
          if c.empty?
            return s.pop
          else
            case c.pop
            in [:variable, name]
              s.push(e.fetch(name))
            in [:definition, parameter, control]
              s.push(Closure.new(e, parameter, control))
            in [:closure, environment, parameter, control]
              s.push(Closure.new(environment, parameter, control))
            in [:constant, name]
              s.push(Constant.new(name))
            in [:apply]
              case s.pop
              in Closure(environment, parameter, control)
                argument = s.pop
                s.push(e, c)
                e, c = environment.merge(parameter => argument), control.dup
              in receiver
                s.push(Call.new(receiver, s.pop))
              end
            in [:return]
              e, c, result = s.pop(3)
              s.push(result)
            end
          end
        end
      end
    end
  end
end
