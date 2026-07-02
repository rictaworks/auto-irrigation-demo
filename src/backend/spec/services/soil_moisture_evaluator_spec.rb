require "rails_helper"

RSpec.describe SoilMoistureEvaluator do
  subject(:evaluator) { described_class.new }

  describe "#validate" do
    it "0〜100%の数値を有効とする" do
      expect(evaluator.validate(0)).to be true
      expect(evaluator.validate(100)).to be true
      expect(evaluator.validate(55.5)).to be true
    end

    it "範囲外の値を無効とする" do
      expect(evaluator.validate(-1)).to be false
      expect(evaluator.validate(100.1)).to be false
    end

    it "数値以外を無効とする" do
      expect(evaluator.validate("50")).to be false
      expect(evaluator.validate(nil)).to be false
    end
  end

  describe "#evaluate" do
    [
      [0, "critical", 1.0],
      [20, "critical", 1.0],
      [21, "needs_irrigation", 0.75],
      [40, "needs_irrigation", 0.75],
      [41, "adequate", 0.0],
      [60, "adequate", 0.0],
      [61, "too_wet", 0.0],
      [80, "too_wet", 0.0],
      [81, "waterlogged", 0.0],
      [100, "waterlogged", 0.0]
    ].each do |moisture, expected_label, expected_score|
      it "#{moisture}% は #{expected_label} (score=#{expected_score}) と判定する" do
        result = evaluator.evaluate(moisture)
        expect(result.label).to eq(expected_label)
        expect(result.score).to eq(expected_score)
      end
    end

    it "範囲外の値は例外を送出する" do
      expect { evaluator.evaluate(150) }.to raise_error(SoilMoistureEvaluator::InvalidMoistureError)
    end
  end
end
