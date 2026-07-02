require "rails_helper"

RSpec.describe SensorReading, type: :model do
  let(:session) { Session.create!(id: SecureRandom.uuid, last_active_at: Time.current) }

  def build_reading(overrides = {})
    described_class.new({
      session: session,
      soil_moisture_pct: 30,
      rainfall_today_mm: 0,
      forecast_rain_mm: 0,
      temperature_c: 20,
      humidity_pct: 50,
      recorded_at: Time.current
    }.merge(overrides))
  end

  it "正しい値なら有効" do
    expect(build_reading).to be_valid
  end

  it "soil_moisture_pctが範囲外なら無効" do
    expect(build_reading(soil_moisture_pct: 150)).not_to be_valid
  end

  it "rainfall_today_mmが負なら無効" do
    expect(build_reading(rainfall_today_mm: -1)).not_to be_valid
  end

  it "humidity_pctが範囲外なら無効" do
    expect(build_reading(humidity_pct: -1)).not_to be_valid
  end

  it "sessionがなければ無効" do
    expect(build_reading(session: nil)).not_to be_valid
  end
end
