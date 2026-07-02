module Api
  class IrrigationsController < BaseController
    def create
      check_honeypot!

      log = current_session.irrigation_logs.create!(irrigation_params.to_h.merge(executed_at: Time.current))
      render json: serialize(log), status: :created
    end

    private

    def irrigation_params
      params.require(:irrigation_log).permit(
        :decision, :soil_moisture, :weather_coeff, :total_score, :recommended_l, :action_taken
      )
    end

    def serialize(log)
      {
        id: log.id,
        decision: log.decision,
        recommended_l: log.recommended_l,
        action_taken: log.action_taken,
        executed_at: log.executed_at.iso8601
      }
    end
  end
end
