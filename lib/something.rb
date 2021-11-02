module Something
  Variable = Struct.new(:name) do
    def inspect = "#{name}"
  end

  Call = Struct.new(:receiver, :argument) do
    def inspect = "#{receiver.inspect}[#{argument.inspect}]"
  end

  Definition = Struct.new(:parameter, :body) do
    def inspect = "-> #{parameter} { #{body.inspect} }"
  end

  def variable(name)
    Variable.new(name)
  end

  def call(receiver, argument)
    Call.new(receiver, argument)
  end

  def definition(parameter, body)
    Definition.new(parameter, body)
  end

  module Translation
    def from_proc(proc)
      return proc unless proc.is_a?(Proc)

      case proc.parameters
      in [[:req, parameter]]
        argument = Variable.new(parameter)
        body = from_proc(with_monkey_patches { proc.call(argument) })
        Definition.new(parameter, body)
      end
    end

    private

    PATCHED_CLASSES = Variable, Call, Proc

    def with_monkey_patches
      original_methods = PATCHED_CLASSES.map { |klass| klass.instance_method(:[]) }

      PATCHED_CLASSES.each do |klass|
        klass.remove_method :[] if klass.method_defined?(:[], false)
        klass.define_method :[] do |argument|
          receiver = Translation.from_proc(self)
          argument = Translation.from_proc(argument)
          Call.new(receiver, argument)
        end
      end

      begin
        yield
      ensure
        PATCHED_CLASSES.zip(original_methods) do |klass, original_method|
          klass.remove_method :[]
          klass.define_method :[], original_method
        end
      end
    end

    module_function :from_proc, :with_monkey_patches
  end
end
