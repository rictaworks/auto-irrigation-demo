require "rails_helper"

RSpec.describe WeatherEvaluator do
  subject(:evaluator) { described_class.new }

  def evaluate(rainfall_today_mm:, forecast_rain_mm:, temperature_c:, humidity_pct:)
    evaluator.evaluate(
      rainfall_today_mm: rainfall_today_mm,
      forecast_rain_mm: forecast_rain_mm,
      temperature_c: temperature_c,
      humidity_pct: humidity_pct
    )
  end

  describe "#validate" do
    it "有効な数値の組み合わせを有効とする" do
      expect(evaluator.validate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 50)).to be true
    end

    it "負の降雨量を無効とする" do
      expect(evaluator.validate(rainfall_today_mm: -1, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 50)).to be false
    end

    it "湿度が0〜100%の範囲外なら無効とする" do
      expect(evaluator.validate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 150)).to be false
    end
  end

  describe "#evaluate（優先順位順）" do
    it "当日降雨量が10mm超なら最優先で係数0.0" do
      result = evaluate(rainfall_today_mm: 10.1, forecast_rain_mm: 100, temperature_c: 40, humidity_pct: 10)
      expect(result.coefficient).to eq(0.0)
      expect(result.reasons).to include("rain_today_over_threshold")
    end

    it "24時間予報降雨量が5mm超なら係数0.3" do
      result = evaluate(rainfall_today_mm: 0, forecast_rain_mm: 5.1, temperature_c: 40, humidity_pct: 10)
      expect(result.coefficient).to eq(0.3)
      expect(result.reasons).to include("forecast_rain_over_threshold")
    end

    it "気温35℃超かつ湿度40%未満なら係数1.5" do
      result = evaluate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 35.1, humidity_pct: 39.9)
      expect(result.coefficient).to eq(1.5)
      expect(result.reasons).to include("hot_and_dry")
    end

    it "気温35℃超でも湿度40%以上なら高温乾燥ルールには該当しない" do
      result = evaluate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 36, humidity_pct: 41)
      expect(result.coefficient).to eq(1.0)
      expect(result.reasons).to include("standard")
    end

    it "気温5℃未満なら係数0.4" do
      result = evaluate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 4.9, humidity_pct: 50)
      expect(result.coefficient).to eq(0.4)
      expect(result.reasons).to include("cold")
    end

    it "湿度80%超なら係数0.6" do
      result = evaluate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 80.1)
      expect(result.coefficient).to eq(0.6)
      expect(result.reasons).to include("high_humidity")
    end

    it "どの条件にも該当しなければ標準の係数1.0" do
      result = evaluate(rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 50)
      expect(result.coefficient).to eq(1.0)
      expect(result.reasons).to include("standard")
    end

    it "不正な値の場合は例外を送出する" do
      expect {
        evaluate(rainfall_today_mm: -1, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 50)
      }.to raise_error(WeatherEvaluator::InvalidConditionsError)
    end
  end
end
