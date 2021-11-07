# Programming with Something

This code accompanies the RubyConf 2021 talk “[Programming with
Something](https://tomstu.art/programming-with-something)”.

It consists of some support files plus a few different evaluators for the
encodings from an earlier talk, “[Programming with
Nothing](https://tomstu.art/programming-with-nothing)”:

* `Nothing` — the [original](https://github.com/tomstuart/nothing) proc
  encodings
* `Something` — an AST to represent those proc encodings, and a translator to
  build ASTs from procs
* `Something::Interpreter` — an AST interpreter
* `Something::RubyVM::Interpreted` — a Ruby implementation of the SECD machine
  which interprets an expression
* `Something::NativeVM::Interpreted` — a C implementation of the SECD machine
  which interprets an expression
* `Something::RubyVM::Compiled` — a Ruby implementation of the SECD machine
  which compiles an expression to commands in advance
* `Something::NativeVM::Compiled` — a C implementation of the SECD machine
  which compiles an expression to commands in advance

To run the tests:

```
$ make
$ bundle install
$ bundle exec rspec
```

To run one of the demo FizzBuzz implementations:

```
$ make
$ bundle exec ruby demo/something_native_vm_compiled.rb
```

Please see the [talk page](https://tomstu.art/programming-with-something) for
more details.
