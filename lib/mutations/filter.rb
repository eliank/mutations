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

    def to_s(name="")
      date_type = self.class.name[/^Mutations::([a-zA-Z]*)Filter$/, 1].downcase
      # data_type = self.class.name.gsub(Mutations::THISFilter, '')  #=> "h{e}ll{o}"
      "#{date_type} :#{name}, #{self.options}"
    end
  end
end
