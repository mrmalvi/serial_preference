require 'spec_helper'

describe SerialPreference::PreferenceDefinition do

  before do
    @blank_pref = described_class.new("whatever")
  end

  it "should have proper accessors" do
    [:data_type, :name, :default, :required, :field_type].each do |a|
      expect(@blank_pref.respond_to?(a)).to be_truthy
    end
  end

  it "should declare supported data types" do
    expect(described_class.constants).to include(:SUPPORTED_TYPES)
  end

  it "should stringify its name" do
    expect(described_class.new(:whatever).name).to eq("whatever")
  end

  context "required behaviour" do
    it "should not be required when no required option provided" do
      expect(@blank_pref).to_not be_required
    end

    it "should be required when required option is truthy" do
      [0,"yes","no","false",true].each do |truthy_values|
        p = described_class.new("whatever",{required: truthy_values})
        expect(p).to be_required
      end
    end

    it "should not be required when required option is falsy" do
      [false,nil].each do |falsy_values|
        p = described_class.new("whatever",{required: falsy_values})
        expect(p).to_not be_required
      end
    end
  end

  context "numericality behaviour" do
    it "should not be numerical when no data_type is provided" do
      expect(@blank_pref).to_not be_numerical
    end

    it "should be numerical when data_type is numerical" do
      [:integer,:float,:decimal].each do |dt|
        expect(described_class.new("whatever",{data_type: dt})).to be_numerical
      end
    end

    it "should be not numerical when data_type is non numerical" do
      [:string,:boolean,:password,:whatever].each do |dt|
        expect(described_class.new("whatever",{data_type: dt})).to_not be_numerical
      end
    end
  end

  context "default behaviour" do
    it "should report correct name" do
      expect(@blank_pref.name).to eq("whatever")
    end
    it "should be a string" do
      expect(@blank_pref.data_type).to eq(:string)
    end
    it "should have nil default" do
      expect(@blank_pref.default).to be_nil
    end
    it "should be false for required" do
      expect(@blank_pref.required).to be_falsy
    end
    it "should have string field_type" do
      expect(@blank_pref.field_type).to eq(:string)
    end
  end

  context "field_type behaviour" do
    it "should report field_type as provided" do
      expect(described_class.new("whatever",{field_type: :xyz}).field_type).to eq(:xyz)
    end
    it "should report string for numerical data types" do
      expect(described_class.new("whatever",{data_type: :integer}).field_type).to eq(:string)
    end
    it "should report data type for non numeric data types" do
      p = described_class.new("whatever",{data_type: :xyz})
      expect(p.field_type).to eq(p.data_type)
    end
  end

  context "should report correct preferred values" do

    context "when input is nil" do
      it "should report nil when no default is given" do
        expect(@blank_pref.value(nil)).to be_nil
      end

      it "should report default when input is nil" do
        p = described_class.new("whatever",{default: "dog"})
        expect(p.value(nil)).to eq("dog")
      end

      it "should report default in appropriate data type when input is nil" do
        p = described_class.new("whatever",{default: "dog", data_type: :integer})
        expect(p.value(nil)).to eq("dog".to_i)
      end
    end

    context "should report correct string/password values" do
      before do
        @preference = described_class.new("whatever",{data_type: :string})
      end

      it "should return correct strings as passthru" do
        ["",3.0,[],{},"dog",1].each do |input_val|
          expect(@preference.value(input_val)).to eq(input_val.to_s)
        end
      end

    end

    context "should report correct integer values" do
      before do
        @preference = described_class.new("whatever",{data_type: :integer})
      end

      it "should return correct integers" do
        ["",1,3.0,"dog"].each do |input_val|
          expect(@preference.value(input_val)).to eq(input_val.to_i)
        end
      end

      it "should report nil for non numeric input" do
        [[],{}].each do |input_val|
          expect(@preference.value(input_val)).to be_nil
        end
      end
    end

    context "should report correct floaty/real values" do
      before do
        @preference = described_class.new("whatever",{data_type: :float})
      end

      it "should return correct floats" do
        ["",1,3.0,"dog"].each do |input_val|
          expect(@preference.value(input_val)).to eq(input_val.to_f)
        end
      end

      it "should report nil for non numeric input" do
        [[],{}].each do |input_val|
          expect(@preference.value(input_val)).to be_nil
        end
      end
    end

    context "should report correct boolean values" do
      before do
        @preference = described_class.new("whatever",{data_type: :boolean})
      end
      it "should report false for falsy values" do
        [nil,false].each do |falsy|
          expect(@preference.value(falsy)).to be_falsy
        end
      end

      it "should report false for false looking values" do
        [0,"0","false","FALSE","False","no","NO","No"].each do |falsy|
          expect(@preference.value(falsy)).to be_falsy
        end
      end

      it "should report true for truthy values" do
        ["yes",true,100,0.1,[],{}].each do |truthy_value|
          expect(@preference.value(truthy_value)).to be_truthy
        end
      end
    end

    context "boolean? behaviour" do
      it "should be boolean when data_type is boolean" do
        p = described_class.new("whatever",{data_type: :boolean})
        expect(p.boolean?).to be_truthy
      end

      it "should not be boolean for non boolean data types" do
        [:string, :integer, :float, :decimal, :password, :xyz].each do |dt|
          expect(described_class.new("whatever",{data_type: dt}).boolean?).to be_falsey
        end
      end
    end

    context "default_value behaviour" do
      it "should return nil when no default is set" do
        expect(@blank_pref.default_value).to be_nil
      end

      it "should return cast default value for integer" do
        p = described_class.new("num",{default: "12", data_type: :integer})
        expect(p.default_value).to eq(12)
      end

      it "should return cast default value for boolean" do
        p = described_class.new("flag",{default: true, data_type: :boolean})
        expect(p.default_value).to be_truthy
      end
    end

    context "normalize_boolean behaviour" do
      before do
        @bool = described_class.new("flag",{data_type: :boolean})
      end

      it "should treat 'yes' as true" do
        expect(@bool.send(:normalize_boolean, "yes")).to be_truthy
      end

      it "should treat 'no' as false" do
        expect(@bool.send(:normalize_boolean, "no")).to be_falsey
      end

      it "should treat 'YES' as true" do
        expect(@bool.send(:normalize_boolean, "YES")).to be_truthy
      end

      it "should treat 'No' as false" do
        expect(@bool.send(:normalize_boolean, "No")).to be_falsey
      end

      it "should treat numeric zero as false" do
        expect(@bool.send(:normalize_boolean, 0)).to be_falsey
      end

      it "should treat numeric '0' as false" do
        expect(@bool.send(:normalize_boolean, '0')).to be_falsey
      end
    end

    context "value method edge cases" do
      it "should return default when value is nil and default exists" do
        p = described_class.new("color",{default: "red"})
        expect(p.value(nil)).to eq("red")
      end

      it "should handle boolean strings properly" do
        p = described_class.new("flag",{data_type: :boolean})
        expect(p.value("true")).to be_truthy
        expect(p.value("false")).to be_falsey
      end

      it "should not coerce non boolean types into boolean" do
        p = described_class.new("mode",{data_type: :string})
        expect(p.value("false")).to eq("false")
      end
    end
  end

end
