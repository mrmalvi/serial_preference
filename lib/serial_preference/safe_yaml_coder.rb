module SerialPreference
  module SafeYamlCoder
    def self.dump(obj)
      YAML.dump(obj)
    end

    def self.load(yaml)
      return {} if yaml.nil?

      Psych.safe_load(yaml, permitted_classes: [Symbol], aliases: true) || {}
    rescue Psych::Exception, TypeError
      YAML.load(yaml) || {}
    end
  end
end
