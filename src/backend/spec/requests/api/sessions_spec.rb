require "rails_helper"

RSpec.describe "GET /api/session", type: :request do
  it "初回アクセス時は新規セッションを発行しCookieにセットする" do
    get "/api/session"

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["session_id"]).to match(SessionManager::UUID_V4_PATTERN)
    expect(Session.exists?(id: body["session_id"])).to be true
    expect(response.cookies["session_id"]).to be_present
  end

  it "既存のセッションCookieがあれば再利用する" do
    get "/api/session"
    session_id = JSON.parse(response.body)["session_id"]

    get "/api/session"
    expect(JSON.parse(response.body)["session_id"]).to eq(session_id)
    expect(Session.count).to eq(1)
  end
end
