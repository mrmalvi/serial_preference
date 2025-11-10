module SerialPreference
  module SafeYamlCoder
    SAFE_CLASSES = [
      Symbol,
      Date,
      Time,
      DateTime,
      BigDecimal,
      ActiveSupport::TimeWithZone,
      ActiveSupport::HashWithIndifferentAccess
    ].freeze

    def self.dump(obj)
      YAML.dump(obj)
    end

    def self.load(yaml)
      return {} if yaml.blank?
      Psych.safe_load(
        yaml,
        permitted_classes: SAFE_CLASSES,
        aliases: true
      ) || {}
    rescue Psych::Exception
      {}
    end
  end
end
