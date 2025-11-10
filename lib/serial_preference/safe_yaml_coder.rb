module SerialPreference
  module SafeYamlCoder
    def self.dump(obj)
      obj = obj.to_h if obj.is_a?(ActiveSupport::HashWithIndifferentAccess)
      YAML.dump(obj)
    end

    def self.load(yaml)
      return {} if yaml.blank?
      Psych.safe_load(
        yaml,
        permitted_classes: [Symbol, ActiveSupport::HashWithIndifferentAccess, Date, Time],
        aliases: true
      ) || {}
    rescue Psych::Exception
      {}
    end
  end
end
