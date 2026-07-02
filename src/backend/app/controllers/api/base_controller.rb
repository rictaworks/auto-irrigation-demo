module Api
  # 全API共通のセッション確認・例外ハンドリング・Bot対策を担う基底コントローラ。
  class BaseController < ApplicationController
    class BotDetectedError < StandardError; end

    SESSION_COOKIE_KEY = :session_id

    before_action :ensure_session!

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
    rescue_from SessionManager::InvalidSessionError, with: :render_bad_request
    rescue_from IrrigationDecisionEngine::InvalidSoilTypeError, with: :render_unprocessable
    rescue_from SoilMoistureEvaluator::InvalidMoistureError, with: :render_unprocessable
    rescue_from WeatherEvaluator::InvalidConditionsError, with: :render_unprocessable
    rescue_from BotDetectedError, with: :render_bot_detected

    private

    attr_reader :current_session

    def session_manager
      @session_manager ||= SessionManager.new
    end

    # セッション固定攻撃対策: リクエストごとにCookieのセッションが有効か確認し、
    # 無効・未発行なら新規発行する。
    def ensure_session!
      trace_id = request.request_id
      cookie_session_id = cookies.signed[SESSION_COOKIE_KEY]

      if cookie_session_id && session_manager.validate_session(cookie_session_id)
        @current_session = Session.find(cookie_session_id)
        @current_session.update!(last_active_at: Time.current)
        Rails.logger.info("[api][#{trace_id}] session reused id=#{@current_session.id}")
      else
        new_id = session_manager.generate_session_id
        @current_session = Session.create!(id: new_id, last_active_at: Time.current)
        set_session_cookie(new_id)
        Rails.logger.info("[api][#{trace_id}] session issued id=#{new_id}")
      end
    end

    def set_session_cookie(session_id)
      cookies.signed[SESSION_COOKIE_KEY] = {
        value: session_id,
        httponly: true,
        same_site: :strict,
        secure: Rails.env.production?
      }
    end

    # 全クエリに WHERE session_id = ? を強制するためのヘルパー。
    def scoped(relation)
      session_manager.scope_query(relation, current_session.id)
    end

    def check_honeypot!
      result = HoneypotChecker.new.check(params.to_unsafe_h)
      raise BotDetectedError if result.is_bot
    end

    def render_not_found(exception)
      Rails.logger.warn("[api][#{request.request_id}] not_found: #{exception.message}")
      render json: { error: "not_found" }, status: :not_found
    end

    def render_unprocessable(exception)
      Rails.logger.warn("[api][#{request.request_id}] unprocessable: #{exception.message}")
      render json: { error: "unprocessable", detail: exception.message }, status: :unprocessable_content
    end

    def render_bad_request(exception)
      Rails.logger.warn("[api][#{request.request_id}] bad_request: #{exception.message}")
      render json: { error: "bad_request" }, status: :bad_request
    end

    # ハニーポット検知時はBotに気付かせないよう200 OKを返し、実処理は行わない。
    def render_bot_detected(_exception = nil)
      Rails.logger.info("[api][#{request.request_id}] bot detected via honeypot")
      render json: { status: "ok" }, status: :ok
    end
  end
end
