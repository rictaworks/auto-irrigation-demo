# UUID v4セッションIDの発行・検証、およびセッションスコープ付きクエリの強制を担当する。
class SessionManager
  UUID_V4_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

  class InvalidSessionError < StandardError; end

  def generate_session_id
    SecureRandom.uuid
  end

  def validate_session(session_id)
    return false unless session_id.is_a?(String)
    return false unless session_id.match?(UUID_V4_PATTERN)

    Session.exists?(id: session_id)
  end

  def scope_query(relation, session_id)
    raise InvalidSessionError, "session_id is required" if session_id.blank?

    relation.where(session_id: session_id)
  end
end
