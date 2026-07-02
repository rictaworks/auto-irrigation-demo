require "rails_helper"

RSpec.describe "POST /api/sensor", type: :request do
  before do
    get "/api/session"
    post "/api/field_settings", params: { field_setting: { area_m2: 100, soil_type: "sandy_loam" } }
  end

  it "土壌水分・天気データを評価し判定結果を返す" do
    post "/api/sensor", params: {
      sensor_reading: {
        soil_moisture_pct: 15,
        rainfall_today_mm: 0,
        forecast_rain_mm: 0,
        temperature_c: 20,
        humidity_pct: 50
      }
    }

    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body["decision"]["level"]).to eq("immediate")
    expect(body["volume"]["volume_l"]).to eq(500)
    expect(body["schedule"]).to be_present
  end

  it "無効な値は422を返す" do
    post "/api/sensor", params: {
      sensor_reading: {
        soil_moisture_pct: 150,
        rainfall_today_mm: 0,
        forecast_rain_mm: 0,
        temperature_c: 20,
        humidity_pct: 50
      }
    }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "ハニーポット検知時は200 OKを返し保存しない" do
    expect {
      post "/api/sensor", params: {
        sensor_reading: { soil_moisture_pct: 15, rainfall_today_mm: 0, forecast_rain_mm: 0, temperature_c: 20, humidity_pct: 50 },
        contact_url: "spam"
      }
    }.not_to change(SensorReading, :count)
    expect(response).to have_http_status(:ok)
  end
end
