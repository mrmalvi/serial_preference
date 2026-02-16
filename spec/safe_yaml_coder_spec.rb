require 'spec_helper'

describe SerialPreference::SafeYamlCoder do
  describe '.load' do
    it 'loads symbols safely when supported by psych' do
      yaml = "---\n:foo: :bar\n"
      data = described_class.load(yaml)
      expect(data).to eq(foo: :bar)
    end
  end
end
