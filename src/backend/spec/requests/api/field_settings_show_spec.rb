require "rails_helper"

RSpec.describe "GET /api/field_settings", type: :request do
  before { get "/api/session" }

  it "未設定の場合はnullを返す" do
    get "/api/field_settings"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_nil
  end

  it "設定済みの場合は最新の圃場設定を返す" do
    post "/api/field_settings", params: { field_setting: { area_m2: 100, soil_type: "loam" } }
    post "/api/field_settings", params: { field_setting: { area_m2: 200, soil_type: "clay" } }

    get "/api/field_settings"

    body = JSON.parse(response.body)
    expect(body["area_m2"]).to eq(200)
    expect(body["soil_type"]).to eq("clay")
  end
end
