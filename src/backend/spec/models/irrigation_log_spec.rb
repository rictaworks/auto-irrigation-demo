require "rails_helper"

RSpec.describe IrrigationLog, type: :model do
  let(:session) { Session.create!(id: SecureRandom.uuid, last_active_at: Time.current) }

  def build_log(overrides = {})
    described_class.new({
      session: session,
      decision: "immediate",
      soil_moisture: 15,
      weather_coeff: 1.0,
      total_score: 1.0,
      recommended_l: 500,
      action_taken: "execute_now",
      executed_at: Time.current
    }.merge(overrides))
  end

  it "正しい値なら有効" do
    expect(build_log).to be_valid
  end

  it "未知のdecisionなら無効" do
    expect(build_log(decision: "unknown")).not_to be_valid
  end

  it "sessionがなければ無効" do
    expect(build_log(session: nil)).not_to be_valid
  end

  it "action_takenが空なら無効" do
    expect(build_log(action_taken: "")).not_to be_valid
  end
end
