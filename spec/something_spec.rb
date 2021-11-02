require 'something'

RSpec.describe Something do
  include Something::Translation

  describe '#from_proc' do
    (
      <<~END
        -> m { -> n { n[-> n { -> p { -> x { p[n[p][x]] } } }][m] } }
        -> x { -> y { x[y] } }
        -> x { -> y { x[y][y][x] } }
        -> y { y }
        -> x { -> y { y }[x] }
        -> f { -> x { f[f[f[x]]] } }
      END
    ).each_line(chomp: true) do |expression|
      it "converts #{expression}" do
        something = from_proc(eval(expression))
        expect(something.inspect).to eq expression
      end
    end
  end
end
