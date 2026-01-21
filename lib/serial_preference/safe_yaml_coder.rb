module SerialPreference
  module SafeYamlCoder

    def self.dump(obj)
      YAML.dump(obj)
    end

    def self.load(yaml)
      Psych.safe_load(yaml, permitted_classes: [Symbol], aliases: true)
    rescue Psych::Exception
      YAML.load(yaml)
    end
  end
end
