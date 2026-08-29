require "rails_helper"

RSpec.describe HexColor do
  describe ".normalize" do
    it "stores six-digit lowercase hex" do
      expect(described_class.normalize("#3D6B5A")).to eq("#3d6b5a")
      expect(described_class.normalize("3d6b5a")).to eq("#3d6b5a")
    end

    it "expands three-digit hex" do
      expect(described_class.normalize("#f0c")).to eq("#ff00cc")
    end

    it "rejects blank and invalid values" do
      expect(described_class.normalize("")).to be_nil
      expect(described_class.normalize("blue")).to be_nil
      expect(described_class.normalize("#gggggg")).to be_nil
    end
  end
end
