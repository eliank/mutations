module Mutations
  class Filter
    @default_options = {}

    def self.default_options
      @default_options
    end

    attr_accessor :options

    def initialize(opts = {})
      self.options = (self.class.default_options || {}).merge(opts)
    end

    # returns -> [sanitized data, error]
    # If an error is returned, then data will be nil
    def filter(data)
      [data, nil]
    end

    def has_default?
      options.has_key?(:default)
    end

    def default
      options[:default]
    end

    # Only relevant for optional params
    def discard_nils?
      !options[:nils]
    end

    def discard_empty?
      options[:discard_empty]
    end

    def data_type
      self.class.name[/^Mutations::([a-zA-Z]*)Filter$/, 1].downcase
    end

    def to_s(name="")
      "#{data_type} :#{name}, #{self.options}"
    end

    def to_hash()
      {:type => data_type, :options => options}
    end
  end
end
