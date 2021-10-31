require 'nothing'
require 'support/evaluation_helpers'

module Nothing
  RSpec.shared_examples 'an encoding of values and operations' do
    include EvaluationHelpers

    describe 'natural numbers' do
      specify { expect(ZERO).to evaluate_to 0 }
      specify { expect(ONE).to evaluate_to 1 }
      specify { expect(TWO).to evaluate_to 2 }
      specify { expect(THREE).to evaluate_to 3 }

      specify { expect([INCREMENT, encoded(2)]).to evaluate_to 2 + 1 }
      specify { expect([ADD, encoded(2), encoded(3)]).to evaluate_to 2 + 3 }
      specify { expect([MULTIPLY, encoded(2), encoded(3)]).to evaluate_to 2 * 3 }
      specify { expect([DECREMENT, encoded(3)]).to evaluate_to 3 - 1 }
      specify { expect([SUBTRACT, encoded(3), encoded(2)]).to evaluate_to 3 - 2 }

      context 'with booleans' do
        (0..3).each do |n|
          specify { expect([IS_ZERO, encoded(n)]).to evaluate_to n.zero? }
          specify { expect([IS_LESS_OR_EQUAL, encoded(n), encoded(2)]).to evaluate_to n <= 2 }
        end
      end

      context 'with recursion' do
        [0, 1, 11, 27].product([1, 3, 11]) do |m, n|
          specify { expect([DIV, encoded(m), encoded(n)]).to evaluate_to m / n }
          specify { expect([MOD, encoded(m), encoded(n)]).to evaluate_to m % n }
        end
      end

      context 'with lists' do
        specify { expect([TO_DIGITS, encoded(42)]).to evaluate_to [4, 2] }
      end
    end

    describe 'booleans' do
      specify { expect(TRUE).to evaluate_to true }
      specify { expect(FALSE).to evaluate_to false }

      specify { expect([IF, encoded(true), encoded(1), encoded(2)]).to evaluate_to 1 }
      specify { expect([IF, encoded(false), encoded(1), encoded(2)]).to evaluate_to 2 }
    end

    describe 'lists' do
      specify { expect(EMPTY).to evaluate_to [] }
      specify { expect([UNSHIFT, encoded([2, 3]), encoded(1)]).to evaluate_to [1, 2, 3] }

      specify { expect([IS_EMPTY, encoded([])]).to evaluate_to true }
      specify { expect([IS_EMPTY, encoded([1])]).to evaluate_to false }
      specify { expect([FIRST, encoded([1, 2, 3])]).to evaluate_to 1 }
      specify { expect([REST, encoded([1, 2, 3])]).to evaluate_to [2, 3] }

      specify { expect([RANGE, TWO, encoded(8)]).to evaluate_to [2, 3, 4, 5, 6, 7, 8] }
      specify { expect([PUSH, encoded([1, 2]), THREE]).to evaluate_to [1, 2, 3] }
    end

    describe 'strings' do
      specify { expect(FIZZ).to evaluate_to 'Fizz' }
    end

    describe 'FizzBuzz' do
      def fizzbuzz(m)
        (1..m).map do |n|
          if (n % 15).zero?
            'FizzBuzz'
          elsif (n % 3).zero?
            'Fizz'
          elsif (n % 5).zero?
            'Buzz'
          else
            n.to_s
          end
        end
      end

      let(:count) { 3 }

      specify do
        results = FIZZBUZZ

        fizzbuzz(count).each do |expected|
          expect([FIRST, results]).to evaluate_to expected
          results = [REST, results]
        end
      end
    end
  end
end
