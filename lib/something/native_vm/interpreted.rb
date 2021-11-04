require 'ffi'
require 'something'
require 'something/native_vm'

GC.disable # keep things simple

module Something
  module NativeVM
    module Interpreted
      include Something::NativeVM

      extend FFI::Library
      ffi_lib File.expand_path('interpreted.so', __dir__)

      enum :types, [:variable, :call, :definition, :closure, :constant]

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
            layout environment: :pointer, parameter: :pointer, body: Expression.ptr
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

      attach_function :evaluate, [Expression.by_ref], Expression.by_ref

      private

      def expression
        Expression.new
      end
    end
  end
end
