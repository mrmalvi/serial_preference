module SerialPreference
  class PreferenceDefinition
    SUPPORTED_TYPES = [:string,:integer,:decimal,:float,:boolean]

    attr_accessor :data_type, :name, :default, :required, :field_type

    def initialize(name, *args)
      opts = args.extract_options!
      opts.assert_valid_keys(:data_type, :default, :required, :field_type)

      self.name       = name.to_s
      self.data_type  = opts[:data_type]&.to_sym || :string
      self.default    = opts[:default]
      self.required   = !!opts[:required]
      self.field_type = opts[:field_type]

      # Use ActiveModel::Type for consistent casting across Rails versions
      begin
        @type = ActiveModel::Type.lookup(self.data_type)
      rescue ArgumentError
        @type = ActiveModel::Type::Value.new
      end
    end

    # Return the name of the preference
    def name
      @name
    end

    def default_value
      default
    end

    def required?
      required
    end

    def numerical?
      [:integer, :float, :decimal].include?(data_type)
    end

    def boolean?
      data_type == :boolean
    end

    # Cast a value using ActiveModel type system
    def type_cast(value)
      v = @type.cast(value)
      v.nil? ? default_value : v
    end

    # Used for UI field mapping, default to string for numeric fields
    def field_type
      @field_type || (numerical? ? :string : data_type)
    end

    # Check if a given value is "truthy" for queries
    def query(value)
      value = type_cast(value)
      return false if value.nil?

      if numerical?
        !value.to_f.zero?
      else
        !value.blank?
      end
    end

    # Value coercion used for serialization
    def value(v)
      v = v.nil? ? default : v
      return nil if v.nil?

      case data_type
      when :string, :password
        v.to_s
      when :integer
        v.is_a?(Integer) ? v : v.try(:to_i)
      when :float, :real, :decimal
        v.is_a?(Numeric) ? v.to_f : v.try(:to_f)
      when :boolean
        boolean_cast(v)
      else
        v
      end
    end

    private

    def boolean_cast(v)
      return v if !v
      if v.is_a?(String)
        return false if v.downcase == "no"
      end

      ActiveModel::Type::Boolean.new.cast(v.to_s.downcase)
    end
  end
end
