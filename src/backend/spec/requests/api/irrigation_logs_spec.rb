require "rails_helper"

RSpec.describe "GET /api/irrigation_logs", type: :request do
  it "当セッションの灌水履歴のみ返す（他セッションのログは含まない）" do
    get "/api/session"

    post "/api/irrigate", params: {
      irrigation_log: {
        decision: "immediate", soil_moisture: 15, weather_coeff: 1.0,
        total_score: 1.0, recommended_l: 500, action_taken: "execute_now"
      }
    }

    other_session = Session.create!(id: SecureRandom.uuid, last_active_at: Time.current)
    IrrigationLog.create!(
      session: other_session, decision: "watch", soil_moisture: 30, weather_coeff: 0.4,
      total_score: 0.3, recommended_l: 100, action_taken: "reevaluate_tomorrow", executed_at: Time.current
    )

    get "/api/irrigation_logs"

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body.length).to eq(1)
    expect(body.first["action_taken"]).to eq("execute_now")
  end
end
