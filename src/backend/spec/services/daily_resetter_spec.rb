require "rails_helper"

RSpec.describe DailyResetter do
  subject(:resetter) { described_class.new }

  describe "#execute_reset" do
    it "全セッションのrainfall_today_mmを0にリセットし、他カラムは変更しない" do
      session = Session.create!(id: SecureRandom.uuid, last_active_at: Time.current)
      reading = SensorReading.create!(
        session: session,
        soil_moisture_pct: 30,
        rainfall_today_mm: 15,
        forecast_rain_mm: 2,
        temperature_c: 25,
        humidity_pct: 50,
        recorded_at: Time.current
      )

      expect(resetter.execute_reset).to be true

      reading.reload
      expect(reading.rainfall_today_mm).to eq(0)
      expect(reading.soil_moisture_pct).to eq(30)
      expect(reading.forecast_rain_mm).to eq(2)
    end

    it "DB更新に失敗した場合は例外を記録し送出する" do
      allow(SensorReading).to receive(:update_all).and_raise(ActiveRecord::StatementInvalid, "boom")

      expect(Rails.logger).to receive(:error).with(a_string_matching(/daily_reset/))
      expect { resetter.execute_reset }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe "#due?" do
    it "JST 03:00台なら true を返す" do
      time = Time.zone.local(2026, 7, 2, 3, 30)
      expect(resetter.due?(time)).to be true
    end

    it "JST 03:00台以外は false を返す" do
      time = Time.zone.local(2026, 7, 2, 4, 0)
      expect(resetter.due?(time)).to be false
    end
  end
end
