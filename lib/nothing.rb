module Nothing
  # In the original “Programming with Nothing”, Ruby evaluated some of the
  # top-level calls at definition time. Here we intend to evaluate everything
  # ourselves so we’d like to ensure that no evaluation happens until we’re
  # explicitly ready for it. The #defer helper method does this by wrapping an
  # expression in a do-nothing proc so that it can’t start evaluating
  # prematurely.

  using Module.new {
    refine Kernel do
      def defer = -> x { yield[x] }
    end
  }

  # https://tomstu.art/programming-with-nothing#numbers

  ZERO  = -> p { -> x {       x    } }
  ONE   = -> p { -> x {     p[x]   } }
  TWO   = -> p { -> x {   p[p[x]]  } }
  THREE = -> p { -> x { p[p[p[x]]] } }

  FIVE    = -> p { -> x { p[p[p[p[p[x]]]]] } }
  FIFTEEN = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]] } }
  HUNDRED = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]] } }

  # https://tomstu.art/programming-with-nothing#booleans

  TRUE  = -> x { -> y { x } }
  FALSE = -> x { -> y { y } }

  IF = -> b { b }

  # https://tomstu.art/programming-with-nothing#predicates

  IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }

  # https://tomstu.art/programming-with-nothing#numeric-operations

  INCREMENT = -> n { -> p { -> x { p[n[p][x]] } } }
  DECREMENT = -> n { -> f { -> x { n[-> g { -> h { h[g[f]] } }] \
                                    [-> y { x }][-> y { y }] } } }

  ADD      = -> m { -> n { n[INCREMENT][m] } }
  SUBTRACT = -> m { -> n { n[DECREMENT][m] } }
  MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }

  IS_LESS_OR_EQUAL =
    -> m { -> n {
      IS_ZERO[SUBTRACT[m][n]]
    } }

  Z = -> f { -> x { f[-> y { x[x][y] }] } \
            [-> x { f[-> y { x[x][y] }] }] }

  MOD =
    defer do
      Z[-> f { -> m { -> n {
        IF[IS_LESS_OR_EQUAL[n][m]][
          -> x {
            f[SUBTRACT[m][n]][n][x]
          }
        ][
          m
        ]
      } } }]
    end

  # https://tomstu.art/programming-with-nothing#lists-briefly

  PAIR  = -> x { -> y { -> f { f[x][y] } } }
  LEFT  = -> p { p[-> x { -> y { x } } ] }
  RIGHT = -> p { p[-> x { -> y { y } } ] }

  EMPTY     = defer { PAIR[TRUE][TRUE] }
  UNSHIFT   = -> l { -> x {
                PAIR[FALSE][PAIR[x][l]]
              } }
  IS_EMPTY  = LEFT
  FIRST     = -> l { LEFT[RIGHT[l]] }
  REST      = -> l { RIGHT[RIGHT[l]] }

  RANGE =
    defer do
      Z[-> f {
        -> m { -> n {
          IF[IS_LESS_OR_EQUAL[m][n]][
            -> x {
              UNSHIFT[f[INCREMENT[m]][n]][m][x]
            }
          ][
            EMPTY
          ]
        } }
      }]
    end

  FOLD =
    defer do
      Z[-> f {
        -> l { -> x { -> g {
          IF[IS_EMPTY[l]][
            x
          ][
            -> y {
              g[f[REST[l]][x][g]][FIRST[l]][y]
            }
          ]
        } } }
      }]
    end

  MAP =
    -> k { -> f {
      FOLD[k][EMPTY][
        -> l { -> x { UNSHIFT[l][f[x]] } }
      ]
    } }

  # https://tomstu.art/programming-with-nothing#strings-briefly

  TEN = defer { MULTIPLY[TWO][FIVE] }
  B   = TEN
  F   = defer { INCREMENT[B] }
  I   = defer { INCREMENT[F] }
  U   = defer { INCREMENT[I] }
  ZED = defer { INCREMENT[U] }

  FIZZ      = defer { UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F] }
  BUZZ      = defer { UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B] }
  FIZZ_BUZZ = defer { UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F] }

  DIV =
    defer do
      Z[-> f { -> m { -> n {
        IF[IS_LESS_OR_EQUAL[n][m]][
          -> x {
            INCREMENT[f[SUBTRACT[m][n]][n]][x]
          }
        ][
          ZERO
        ]
      } } }]
    end

  PUSH =
    -> l {
      -> x {
        FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]
      }
    }

  TO_DIGITS =
    defer do
      Z[-> f { -> n { PUSH[
        IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][
          EMPTY
        ][
          -> x {
            f[DIV[n][TEN]][x]
          }
        ]
      ][MOD[n][TEN]] } }]
    end

  # https://tomstu.art/programming-with-nothing#victory

  FIZZBUZZ =
    defer do
      MAP[RANGE[ONE][HUNDRED]][-> n {
        IF[IS_ZERO[MOD[n][FIFTEEN]]][
          FIZZ_BUZZ
        ][IF[IS_ZERO[MOD[n][THREE]]][
          FIZZ
        ][IF[IS_ZERO[MOD[n][FIVE]]][
          BUZZ
        ][
          TO_DIGITS[n]
        ]]]
      }]
    end

  module Translation
    def to_integer(n)
      n[:succ.to_proc][0]
    end

    def from_integer(integer)
      integer.times.inject(ZERO) { |n| INCREMENT[n] }
    end

    def to_boolean(b)
      IF[b][true][false]
    end

    def from_boolean(boolean)
      boolean ? TRUE : FALSE
    end

    def each_element(l)
      return enum_for(__method__, l) unless block_given?

      until to_boolean(IS_EMPTY[l])
        yield FIRST[l]
        l = REST[l]
      end
    end

    def to_array(l)
      each_element(l).entries
    end

    def from_array(array)
      array.reverse_each.inject(EMPTY) { |l, x| UNSHIFT[l][x] }
    end

    CHARSET = '0123456789BFiuz' # for encoding digits, “Fizz” and “Buzz”

    def to_string(s)
      each_element(s).map { |c| CHARSET.slice(to_integer(c)) }.join
    end
  end
end
