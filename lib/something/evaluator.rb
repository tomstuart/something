require 'nothing'
require 'something'

module Something
  module Evaluator
    include Something

    Constant = Struct.new(:name) do
      def inspect = "#{name}"
    end

    def constant(name)
      Constant.new(name)
    end

    module Translation
      include Nothing::Translation
      include Something::Translation

      def to_integer(n)
        increment = constant('INCREMENT')
        zero = constant('ZERO')
        expression = evaluate(call(call(n, increment), zero))
        identify_integer(expression, increment, zero)
      end

      def identify_integer(expression, increment, zero)
        integer = 0

        loop do
          case expression
          in Call(^increment, expression)
            integer += 1
          in ^zero
            return integer
          end
        end
      end

      def to_boolean(b)
        yes = constant('YES')
        no = constant('NO')
        expression = evaluate(call(call(b, yes), no))
        identify_boolean(expression, yes, no)
      end

      def identify_boolean(expression, yes, no)
        case expression
        in ^yes
          true
        in ^no
          false
        end
      end

      def each_element(l)
        return enum_for(__method__, l) unless block_given?

        first = from_proc(Nothing::FIRST)
        rest = from_proc(Nothing::REST)
        is_empty = from_proc(Nothing::IS_EMPTY)

        until to_boolean(evaluate(call(is_empty, l)))
          yield evaluate(call(first, l))
          l = evaluate(call(rest, l))
        end
      end
    end
  end
end
