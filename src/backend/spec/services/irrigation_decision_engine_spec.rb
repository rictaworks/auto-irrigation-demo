require "rails_helper"

RSpec.describe IrrigationDecisionEngine do
  subject(:engine) { described_class.new }

  describe "#calculate_need" do
    it "総合スコアが0.7以上なら今すぐ灌水(immediate)" do
      result = engine.calculate_need(soil_score: 1.0, weather_coefficient: 1.0)
      expect(result.level).to eq("immediate")
      expect(result.total_score).to eq(1.0)
    end

    it "総合スコアが0.4〜0.69なら灌水推奨(recommended)" do
      result = engine.calculate_need(soil_score: 0.75, weather_coefficient: 0.6)
      expect(result.total_score).to be_within(0.0001).of(0.45)
      expect(result.level).to eq("recommended")
    end

    it "総合スコアが0.2〜0.39なら様子見(watch)" do
      result = engine.calculate_need(soil_score: 0.75, weather_coefficient: 0.4)
      expect(result.total_score).to be_within(0.0001).of(0.3)
      expect(result.level).to eq("watch")
    end

    it "総合スコアが0.2未満なら灌水不要(none)" do
      result = engine.calculate_need(soil_score: 0.0, weather_coefficient: 1.0)
      expect(result.total_score).to eq(0.0)
      expect(result.level).to eq("none")
    end
  end

  describe "#calculate_volume" do
    it "今すぐ灌水×砂壌土×100m²で500L" do
      result = engine.calculate_volume(level: "immediate", area_m2: 100, soil_type: "sandy_loam")
      expect(result.volume_l).to eq(500)
    end

    it "灌水推奨×粘土質×50m²で100L" do
      result = engine.calculate_volume(level: "recommended", area_m2: 50, soil_type: "clay")
      expect(result.volume_l).to eq(100)
    end

    it "灌水不要はどの土壌種別でも0L" do
      result = engine.calculate_volume(level: "none", area_m2: 100, soil_type: "loam")
      expect(result.volume_l).to eq(0)
    end

    it "未知の土壌種別は例外を送出する" do
      expect {
        engine.calculate_volume(level: "immediate", area_m2: 100, soil_type: "unknown")
      }.to raise_error(IrrigationDecisionEngine::InvalidSoilTypeError)
    end
  end

  describe "#schedule" do
    it "今すぐ灌水×10-16時×気温30℃超は夕方まで待機" do
      result = engine.schedule(level: "immediate", current_hour_jst: 12, temperature_c: 31)
      expect(result.action).to eq("wait_until_evening")
      expect(result.recommended_hour).to eq(17)
    end

    it "今すぐ灌水×10-16時でも気温30℃以下は今すぐ実行" do
      result = engine.schedule(level: "immediate", current_hour_jst: 12, temperature_c: 25)
      expect(result.action).to eq("execute_now")
    end

    it "今すぐ灌水×22-5時(日跨ぎ)は緊急灌水モード" do
      expect(engine.schedule(level: "immediate", current_hour_jst: 23, temperature_c: 20).action).to eq("emergency_confirm")
      expect(engine.schedule(level: "immediate", current_hour_jst: 2, temperature_c: 20).action).to eq("emergency_confirm")
    end

    it "今すぐ灌水×それ以外の時間帯は今すぐ実行" do
      result = engine.schedule(level: "immediate", current_hour_jst: 8, temperature_c: 20)
      expect(result.action).to eq("execute_now")
    end

    it "灌水推奨は翌朝6-8時を推奨" do
      result = engine.schedule(level: "recommended", current_hour_jst: 20, temperature_c: 20)
      expect(result.action).to eq("next_morning")
      expect(result.recommended_hour).to eq(6)
    end

    it "様子見は翌日の朝再評価" do
      result = engine.schedule(level: "watch", current_hour_jst: 20, temperature_c: 20)
      expect(result.action).to eq("reevaluate_tomorrow")
    end

    it "灌水不要はスキップ" do
      result = engine.schedule(level: "none", current_hour_jst: 20, temperature_c: 20)
      expect(result.action).to eq("skip")
    end

    it "未知のlevelは例外を送出する" do
      expect {
        engine.schedule(level: "bogus", current_hour_jst: 12, temperature_c: 20)
      }.to raise_error(ArgumentError)
    end
  end
end
