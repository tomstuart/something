require 'ffi'
require 'something'
require 'something/native_vm'

GC.disable # keep things simple

module Something
  module NativeVM
    module Compiled
      include Something::NativeVM

      extend FFI::Library
      ffi_lib File.expand_path('compiled.so', __dir__)

      enum :types, [:variable, :call, :definition, :closure, :constant]

      class Control < FFI::Struct; end

      class Expression < FFI::Struct
        class Data < FFI::Union
          class Named < FFI::Struct
            layout name: :pointer
          end
          class Call < FFI::Struct
            layout receiver: Expression.ptr, argument: Expression.ptr
          end
          class Definition < FFI::Struct
            layout parameter: :pointer, body: Expression.ptr
          end
          class Closure < FFI::Struct
            layout environment: :pointer, parameter: :pointer, control: Control.ptr
          end

          layout \
            variable: Named,
            call: Call,
            definition: Definition,
            closure: Closure,
            constant: Named
        end

        layout type: :types, data: Data
      end

      class Control
        class Command < FFI::Struct
          class Data < FFI::Union
            class Named < FFI::Struct
              layout name: :pointer
            end
            class Definition < FFI::Struct
              layout parameter: :pointer, control: Control.ptr
            end
            class Closure < FFI::Struct
              layout environment: :pointer, parameter: :pointer, control: Control.ptr
            end

            layout \
              variable: Named,
              definition: Definition,
              closure: Closure,
              constant: Named
          end

          layout \
            type: FFI::Enum.new([
              :variable, :apply, :return, :definition, :constant, :closure
            ]),
            data: Data
        end

        layout command: Command, rest: Control.ptr
      end

      attach_function :execute, [Control.by_ref], Expression.by_ref

      def evaluate(expression)
        execute(compile(expression, nil))
      end

      private

      def expression
        Expression.new
      end

      def compile(expression, rest)
        result = Control.new
        result[:rest] = rest
        command = result[:command]

        data = expression[:data][type = expression[:type]]

        case type
        in :variable
          name = data[:name]
          data = command[:data][command[:type] = :variable]
          data[:name] = name
        in :call
          receiver, argument = data[:receiver], data[:argument]
          command[:type] = :apply
          result = compile(argument, compile(receiver, result))
        in :definition
          parameter, body = data[:parameter], data[:body]
          data = command[:data][command[:type] = :definition]
          data[:parameter] = parameter
          data[:control] =
            compile(
              body,
              Control.new.tap do |control|
                control[:command][:type] = :return
                control[:rest] = nil
              end
            )
        in :constant
          name = data[:name]
          data = command[:data][command[:type] = :constant]
          data[:name] = name
        in :closure
          environment, parameter, control = data[:environment], data[:parameter], data[:control]
          data = command[:data][command[:type] = :closure]
          data[:environment] = environment
          data[:parameter] = parameter
          data[:control] = control
        end

        result
      end
    end
  end
end
