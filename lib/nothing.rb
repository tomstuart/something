module Nothing
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
    Z[-> f { -> m { -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][
        -> x {
          f[SUBTRACT[m][n]][n][x]
        }
      ][
        m
      ]
    } } }]

  # https://tomstu.art/programming-with-nothing#lists-briefly

  PAIR  = -> x { -> y { -> f { f[x][y] } } }
  LEFT  = -> p { p[-> x { -> y { x } } ] }
  RIGHT = -> p { p[-> x { -> y { y } } ] }

  EMPTY     = PAIR[TRUE][TRUE]
  UNSHIFT   = -> l { -> x {
                PAIR[FALSE][PAIR[x][l]]
              } }
  IS_EMPTY  = LEFT
  FIRST     = -> l { LEFT[RIGHT[l]] }
  REST      = -> l { RIGHT[RIGHT[l]] }

  RANGE =
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

  FOLD =
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

  MAP =
    -> k { -> f {
      FOLD[k][EMPTY][
        -> l { -> x { UNSHIFT[l][f[x]] } }
      ]
    } }

  # https://tomstu.art/programming-with-nothing#strings-briefly

  TEN = MULTIPLY[TWO][FIVE]
  B   = TEN
  F   = INCREMENT[B]
  I   = INCREMENT[F]
  U   = INCREMENT[I]
  ZED = INCREMENT[U]

  FIZZ      = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
  BUZZ      = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
  FIZZ_BUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]

  DIV =
    Z[-> f { -> m { -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][
        -> x {
          INCREMENT[f[SUBTRACT[m][n]][n]][x]
        }
      ][
        ZERO
      ]
    } } }]

  PUSH =
    -> l {
      -> x {
        FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]
      }
    }

  TO_DIGITS =
    Z[-> f { -> n { PUSH[
      IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][
        EMPTY
      ][
        -> x {
          f[DIV[n][TEN]][x]
        }
      ]
    ][MOD[n][TEN]] } }]

  # https://tomstu.art/programming-with-nothing#victory

  FIZZBUZZ =
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
