module Api
  class SessionsController < BaseController
    def show
      render json: { session_id: current_session.id }
    end
  end
end
