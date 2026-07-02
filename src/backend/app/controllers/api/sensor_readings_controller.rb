module Api
  class SensorReadingsController < BaseController
    def create
      check_honeypot!

      soil_result = SoilMoistureEvaluator.new.evaluate(sensor_params[:soil_moisture_pct].to_f)
      weather_result = WeatherEvaluator.new.evaluate(
        rainfall_today_mm: sensor_params[:rainfall_today_mm].to_f,
        forecast_rain_mm: sensor_params[:forecast_rain_mm].to_f,
        temperature_c: sensor_params[:temperature_c].to_f,
        humidity_pct: sensor_params[:humidity_pct].to_f
      )

      engine = IrrigationDecisionEngine.new
      need = engine.calculate_need(soil_score: soil_result.score, weather_coefficient: weather_result.coefficient)
      volume = calculate_volume(engine, need.level)
      schedule = engine.schedule(
        level: need.level,
        current_hour_jst: Time.current.hour,
        temperature_c: sensor_params[:temperature_c].to_f
      )

      reading = current_session.sensor_readings.create!(sensor_params.to_h.merge(recorded_at: Time.current))

      render json: {
        sensor_reading_id: reading.id,
        soil: { label: soil_result.label, score: soil_result.score },
        weather: { coefficient: weather_result.coefficient, reasons: weather_result.reasons },
        decision: { level: need.level, total_score: need.total_score },
        volume: volume && { volume_l: volume.volume_l },
        schedule: { action: schedule.action, recommended_hour: schedule.recommended_hour }
      }, status: :created
    end

    private

    def calculate_volume(engine, level)
      field_setting = current_session.field_settings.order(created_at: :desc).first
      return nil unless field_setting

      engine.calculate_volume(level: level, area_m2: field_setting.area_m2, soil_type: field_setting.soil_type)
    end

    def sensor_params
      params.require(:sensor_reading).permit(
        :soil_moisture_pct, :rainfall_today_mm, :forecast_rain_mm, :temperature_c, :humidity_pct
      )
    end
  end
end
