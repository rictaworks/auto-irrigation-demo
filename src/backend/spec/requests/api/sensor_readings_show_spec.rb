require "rails_helper"

RSpec.describe "GET /api/sensor", type: :request do
  before do
    get "/api/session"
    post "/api/field_settings", params: { field_setting: { area_m2: 100, soil_type: "sandy_loam" } }
  end

  it "センサー未入力の場合はnullを返す" do
    get "/api/sensor"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_nil
  end

  it "直近のセンサー入力を再評価して返す" do
    post "/api/sensor", params: {
      sensor_reading: {
        soil_moisture_pct: 15, rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 50
      }
    }

    get "/api/sensor"

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["decision"]["level"]).to eq("immediate")
    expect(body["volume"]["volume_l"]).to eq(500)
    expect(body["sensor"]["soil_moisture_pct"]).to eq(15)
  end
end
