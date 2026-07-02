module Api
  class IrrigationLogsController < BaseController
    def index
      logs = scoped(IrrigationLog.all).order(executed_at: :desc)
      render json: logs.map { |log| serialize(log) }
    end

    private

    def serialize(log)
      {
        id: log.id,
        decision: log.decision,
        soil_moisture: log.soil_moisture,
        total_score: log.total_score,
        recommended_l: log.recommended_l,
        action_taken: log.action_taken,
        executed_at: log.executed_at.iso8601
      }
    end
  end
end
