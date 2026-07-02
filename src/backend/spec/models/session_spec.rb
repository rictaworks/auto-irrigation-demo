require "rails_helper"

RSpec.describe Session, type: :model do
  it "id, last_active_atがあれば有効" do
    session = described_class.new(id: SecureRandom.uuid, last_active_at: Time.current)
    expect(session).to be_valid
  end

  it "idがなければ無効" do
    session = described_class.new(id: nil, last_active_at: Time.current)
    expect(session).not_to be_valid
  end

  it "紐づくfield_settings/sensor_readings/irrigation_logsを持つ" do
    session = described_class.create!(id: SecureRandom.uuid, last_active_at: Time.current)
    expect(session.field_settings).to eq([])
    expect(session.sensor_readings).to eq([])
    expect(session.irrigation_logs).to eq([])
  end
end
