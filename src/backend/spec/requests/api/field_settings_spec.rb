require "rails_helper"

RSpec.describe "POST /api/field_settings", type: :request do
  before { get "/api/session" }

  it "圃場設定を登録できる" do
    post "/api/field_settings", params: { field_setting: { area_m2: 100, soil_type: "loam" } }

    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body["area_m2"]).to eq(100)
    expect(body["soil_type"]).to eq("loam")
  end

  it "未知のsoil_typeは422を返す" do
    post "/api/field_settings", params: { field_setting: { area_m2: 100, soil_type: "granite" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "ハニーポットフィールドに値があれば200 OKを返しつつ保存しない" do
    expect {
      post "/api/field_settings", params: { field_setting: { area_m2: 100, soil_type: "loam" }, contact_url: "spam" }
    }.not_to change(FieldSetting, :count)

    expect(response).to have_http_status(:ok)
  end
end
