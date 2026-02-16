module SerialPreference
  module SafeYamlCoder
    def self.dump(obj)
      YAML.dump(obj)
    end

    def self.load(yaml)
      return {} if yaml.nil?

      safe_load_with_symbols(yaml) || {}
    end

    def self.safe_load_with_symbols(yaml)
      Psych.safe_load(yaml, permitted_classes: [Symbol], aliases: true)
    rescue ArgumentError
      # Psych < 3 uses positional args: safe_load(yaml, whitelist_classes, whitelist_symbols, aliases)
      Psych.safe_load(yaml, [Symbol], [], true)
    end
  end
end
