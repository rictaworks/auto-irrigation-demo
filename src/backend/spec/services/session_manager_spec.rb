require "rails_helper"

RSpec.describe SessionManager do
  subject(:manager) { described_class.new }

  describe "#generate_session_id" do
    it "UUID v4形式の文字列を発行する" do
      id = manager.generate_session_id
      expect(id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
    end

    it "呼び出すたびに異なるIDを発行する" do
      expect(manager.generate_session_id).not_to eq(manager.generate_session_id)
    end
  end

  describe "#validate_session" do
    it "DBに存在するセッションIDは有効" do
      session = Session.create!(id: SecureRandom.uuid, last_active_at: Time.current)
      expect(manager.validate_session(session.id)).to be true
    end

    it "DBに存在しないセッションIDは無効" do
      expect(manager.validate_session(SecureRandom.uuid)).to be false
    end

    it "UUID形式でない値は無効" do
      expect(manager.validate_session("not-a-uuid")).to be false
    end

    it "nilは無効" do
      expect(manager.validate_session(nil)).to be false
    end
  end

  describe "#scope_query" do
    it "session_idでWHERE句を付与したリレーションを返す" do
      session_a = Session.create!(id: SecureRandom.uuid, last_active_at: Time.current)
      session_b = Session.create!(id: SecureRandom.uuid, last_active_at: Time.current)
      FieldSetting.create!(session: session_a, area_m2: 10, soil_type: "loam")
      FieldSetting.create!(session: session_b, area_m2: 20, soil_type: "clay")

      result = manager.scope_query(FieldSetting.all, session_a.id)

      expect(result.count).to eq(1)
      expect(result.first.session_id).to eq(session_a.id)
    end

    it "session_idが空なら例外を送出する" do
      expect { manager.scope_query(FieldSetting.all, nil) }.to raise_error(SessionManager::InvalidSessionError)
    end
  end
end
