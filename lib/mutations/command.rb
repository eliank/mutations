module Mutations
  class Command
    class << self
      def construct(serialized_command)
        instance_eval(serialized_command)
      end

      def input(&block)
        @current_filters = self.input_filters
        instance_eval(&block)
      end

      def output(&block)
        @current_filters = self.output_filters
        instance_eval(&block)
      end

      def required(&block)
        @current_filters.send(:required, &block)
      end

      def optional(&block)
        @current_filters.send(:optional, &block)
      end

      def run(*args)
        new(*args).run
      end

      def run!(*args)
        new(*args).run!
      end

      # Validates input, but doesn't call execute. Returns an Outcome with errors anyway.
      def validate(*args)
        new(*args).validate
      end

      def validate!(*args)
        new(*args).validate!
      end

      def input_filters
        @input_filters ||= begin
          if Command == self.superclass
            HashFilter.new
          else
            self.superclass.input_filters.dup
          end
        end
      end

      def output_filters
        @output_filters ||= begin
          if Command == self.superclass
            HashFilter.new
          else
            self.superclass.output_filters.dup
          end
        end
      end
    end

    def to_s
      %(
        input do
          #{input_filters.to_s}
        end

        output do
          #{output_filters.to_s}
        end
      )
    end

    # Instance methods
    def initialize(*args)
      @raw_inputs = args.each_with_object({}.with_indifferent_access) do |arg, h|
        raise ArgumentError.new("All arguments must be hashes") unless arg.is_a?(Hash)
        h.merge!(arg)
      end
      
      @inputs, @errors = self.input_filters.filter(@raw_inputs)
    end

    def input_filters
      self.class.input_filters
    end

    def output_filters
      self.class.output_filters
    end

    def has_errors?
      !@errors.nil?
    end

    def run
      return validation_outcome if has_errors?
      validation_outcome(execute)
    end

    def run!
      outcome = run
      if outcome.success?
        outcome.result
      else
        raise ValidationException.new(outcome.errors)
      end
    end

    def validate
      validation_outcome
    end

    def validate!
      outcome = validate
      if outcome.success?
        outcome.result
      else
        raise ValidationException.new(outcome.errors)
      end
    end

    def validation_outcome(result = nil)
      Outcome.new(!has_errors?, has_errors? ? nil : result, @errors, @inputs)
    end

  protected

    attr_reader :inputs, :raw_inputs

    def execute
      # Meant to be overridden
    end

    # add_error("name", :too_short)
    # add_error("colors.foreground", :not_a_color) # => to create errors = {colors: {foreground: :not_a_color}}
    # or, supply a custom message:
    # add_error("name", :too_short, "The name 'blahblahblah' is too short!")
    def add_error(key, kind, message = nil)
      raise ArgumentError.new("Invalid kind") unless kind.is_a?(Symbol)

      @errors ||= ErrorHash.new
      @errors.tap do |errs|
        *path, last = key.to_s.split(".")
        inner = path.inject(errs) do |cut_errors,part|
          cur_errors[part.to_sym] ||= ErrorHash.new
        end
        inner[last] = ErrorAtom.new(key, kind, message: message)
      end
    end

    def merge_errors(hash)
      @errors ||= ErrorHash.new
      @errors.merge!(hash)
    end
  end
end
