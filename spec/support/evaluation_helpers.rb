module EvaluationHelpers
  extend RSpec::Matchers::DSL

  matcher :evaluate_to do |value|
    match do |sexp|
      encodes?(apply_calls(sexp), value)
    end

    def encodes?(expression, value)
      case value
      in Integer
        to_integer(expression) == value
      in TrueClass | FalseClass
        to_boolean(expression) == value
      in Array
        begin
          [to_array(expression), value].transpose.all? { |p, v| encodes?(p, v) }
        rescue IndexError
          false
        end
      in String
        to_string(expression) == value
      end
    end
  end

  def apply_calls(sexp)
    case sexp
    in [last]
      apply_calls(last)
    in [*rest, last]
      call(apply_calls(rest), apply_calls(last))
    else
      from_proc(sexp)
    end
  end

  def encoded(value)
    case value
    in Integer
      from_integer(value)
    in TrueClass | FalseClass
      from_boolean(value)
    in Array
      from_array(value.map { |v| encoded(v) })
    end
  end
end
