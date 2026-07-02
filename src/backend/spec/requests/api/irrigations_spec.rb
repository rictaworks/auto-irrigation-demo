require "rails_helper"

RSpec.describe "POST /api/irrigate", type: :request do
  before { get "/api/session" }

  it "灌水実行を記録できる" do
    post "/api/irrigate", params: {
      irrigation_log: {
        decision: "immediate",
        soil_moisture: 15,
        weather_coeff: 1.0,
        total_score: 1.0,
        recommended_l: 500,
        action_taken: "execute_now"
      }
    }

    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body["decision"]).to eq("immediate")
    expect(IrrigationLog.count).to eq(1)
  end

  it "ハニーポット検知時は200 OKを返し保存しない" do
    expect {
      post "/api/irrigate", params: {
        irrigation_log: {
          decision: "immediate", soil_moisture: 15, weather_coeff: 1.0,
          total_score: 1.0, recommended_l: 500, action_taken: "execute_now"
        },
        contact_url: "spam"
      }
    }.not_to change(IrrigationLog, :count)
    expect(response).to have_http_status(:ok)
  end
end
