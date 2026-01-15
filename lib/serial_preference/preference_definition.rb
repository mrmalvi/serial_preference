module SerialPreference
  class PreferenceDefinition

    SUPPORTED_TYPES = [:string,:integer,:decimal,:float,:boolean]

    attr_accessor :data_type, :name, :default, :required, :field_type

    def initialize(name,*args)
      opts = args.extract_options!
      self.name = name.to_s
      opts.assert_valid_keys(:data_type, :default, :required, :field_type)
      self.data_type = @type = opts[:data_type] || :string
      @type_caster = column_type(@type)
      self.default = opts[:default]
      self.required = !!opts[:required]
      self.field_type = opts[:field_type]
    end

    def default_value
      type_cast(default)
    end

    def required?
      required
    end

    def numerical?
      [:integer, :float, :decimal].include?(@type_caster.type)
    end

    def boolean?
      @type_caster.type == :boolean
    end

    def type_cast(value)
      v = @type_caster.cast(value)
      v.nil? ? default_value : v
    end

    def field_type
      @field_type || (numerical? ? :string : data_type)
    end

    def query(value)
      if !(value = type_cast(value))
        false
      elsif numerical?
        !value.zero?
      else
        !value.blank?
      end
    end

    def value(v)
      v = v.nil? ? default : v
      if !v.nil?
        case data_type
        when :string, :password
          v.to_s
        when :integer
          v.respond_to?(:to_i) ? v.to_i : nil
        when :float, :real
          v.respond_to?(:to_f) ? v.to_f : nil
        when :boolean
          !!normalize_boolean(v)
        else
          nil
        end
      end
    end

    private

    def column_type(type)
      begin
        ActiveModel::Type.lookup(type)
      rescue ArgumentError
        ActiveRecord::Type::String.new
      end
    end

    def normalize_boolean(v)
      return false if !v || (v.is_a?(String) && (v.downcase == "no"))

      ActiveModel::Type::Boolean.new.cast(v.to_s.downcase)
    end
  end
end
