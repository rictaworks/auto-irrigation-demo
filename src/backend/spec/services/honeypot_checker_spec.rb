require "rails_helper"

RSpec.describe HoneypotChecker do
  subject(:checker) { described_class.new }

  it "隠しフィールドが空ならBotではないと判定する" do
    result = checker.check({ "soil_moisture_pct" => 30, "contact_url" => "" })
    expect(result.is_bot).to be false
  end

  it "隠しフィールドが未指定でもBotではないと判定する" do
    result = checker.check({ "soil_moisture_pct" => 30 })
    expect(result.is_bot).to be false
  end

  it "隠しフィールドに値が入っていたらBotと判定する" do
    result = checker.check({ "soil_moisture_pct" => 30, "contact_url" => "http://spam.example.com" })
    expect(result.is_bot).to be true
  end

  it "シンボルキーのform_dataでも判定できる" do
    result = checker.check({ contact_url: "spam" })
    expect(result.is_bot).to be true
  end
end
