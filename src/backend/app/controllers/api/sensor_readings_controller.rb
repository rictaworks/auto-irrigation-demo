module Api
  class SensorReadingsController < BaseController
    def show
      reading = current_session.sensor_readings.order(recorded_at: :desc).first
      render json: reading && build_assessment(reading)
    end

    def create
      check_honeypot!

      reading = current_session.sensor_readings.create!(sensor_params.to_h.merge(recorded_at: Time.current))
      render json: build_assessment(reading), status: :created
    end

    private

    def build_assessment(reading)
      soil_result = SoilMoistureEvaluator.new.evaluate(reading.soil_moisture_pct)
      weather_result = WeatherEvaluator.new.evaluate(
        rainfall_today_mm: reading.rainfall_today_mm,
        forecast_rain_mm: reading.forecast_rain_mm,
        temperature_c: reading.temperature_c,
        humidity_pct: reading.humidity_pct
      )

      engine = IrrigationDecisionEngine.new
      need = engine.calculate_need(soil_score: soil_result.score, weather_coefficient: weather_result.coefficient)
      volume = calculate_volume(engine, need.level)
      schedule = engine.schedule(
        level: need.level,
        current_hour_jst: Time.current.hour,
        temperature_c: reading.temperature_c
      )

      {
        sensor_reading_id: reading.id,
        recorded_at: reading.recorded_at.iso8601,
        soil: { label: soil_result.label, score: soil_result.score },
        weather: { coefficient: weather_result.coefficient, reasons: weather_result.reasons },
        decision: { level: need.level, total_score: need.total_score },
        volume: volume && { volume_l: volume.volume_l },
        schedule: { action: schedule.action, recommended_hour: schedule.recommended_hour },
        sensor: {
          soil_moisture_pct: reading.soil_moisture_pct,
          rainfall_today_mm: reading.rainfall_today_mm,
          forecast_rain_mm: reading.forecast_rain_mm,
          temperature_c: reading.temperature_c,
          humidity_pct: reading.humidity_pct
        }
      }
    end

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
