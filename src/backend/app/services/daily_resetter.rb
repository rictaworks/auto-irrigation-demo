# JST 03:00 に全セッション分の当日降雨量カウンターをリセットする。
class DailyResetter
  def initialize(reset_hour_jst: IrrigationRules.load.fetch(:daily_reset).fetch(:reset_hour_jst))
    @reset_hour_jst = reset_hour_jst
  end

  def execute_reset
    trace_id = SecureRandom.uuid
    Rails.logger.info("[daily_reset][#{trace_id}] start rainfall_today_mm reset")

    SensorReading.update_all(rainfall_today_mm: 0)

    Rails.logger.info("[daily_reset][#{trace_id}] completed")
    true
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("[daily_reset] failed: #{e.class}: #{e.message}")
    raise
  end

  def due?(time_jst)
    time_jst.hour == @reset_hour_jst
  end
end
