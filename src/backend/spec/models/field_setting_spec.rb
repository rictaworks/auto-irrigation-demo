require "rails_helper"

RSpec.describe FieldSetting, type: :model do
  let(:session) { Session.create!(id: SecureRandom.uuid, last_active_at: Time.current) }

  it "session, area_m2, soil_typeが正しければ有効" do
    setting = described_class.new(session: session, area_m2: 100, soil_type: "loam")
    expect(setting).to be_valid
  end

  it "area_m2が0以下なら無効" do
    setting = described_class.new(session: session, area_m2: 0, soil_type: "loam")
    expect(setting).not_to be_valid
  end

  it "未知のsoil_typeなら無効" do
    setting = described_class.new(session: session, area_m2: 100, soil_type: "granite")
    expect(setting).not_to be_valid
  end

  it "sessionがなければ無効" do
    setting = described_class.new(session: nil, area_m2: 100, soil_type: "loam")
    expect(setting).not_to be_valid
  end
end
