# 降雨量・予報・気温・湿度から天気係数を算出する。
# ルールは優先順位順に評価し、最初にマッチしたものを採用する。
class WeatherEvaluator
  Result = Struct.new(:coefficient, :reasons, keyword_init: true)

  class InvalidConditionsError < StandardError; end

  def initialize(rules: IrrigationRules.load.fetch(:weather))
    @rules = rules
  end

  def validate(rainfall_today_mm:, forecast_rain_mm:, temperature_c:, humidity_pct:)
    values = [rainfall_today_mm, forecast_rain_mm, temperature_c, humidity_pct]
    return false unless values.all? { |v| v.is_a?(Numeric) }

    rainfall_today_mm >= 0 && forecast_rain_mm >= 0 && humidity_pct.between?(0, 100)
  end

  def evaluate(rainfall_today_mm:, forecast_rain_mm:, temperature_c:, humidity_pct:)
    unless validate(
      rainfall_today_mm: rainfall_today_mm,
      forecast_rain_mm: forecast_rain_mm,
      temperature_c: temperature_c,
      humidity_pct: humidity_pct
    )
      raise InvalidConditionsError, "invalid weather conditions: rainfall_today_mm=#{rainfall_today_mm.inspect}, " \
        "forecast_rain_mm=#{forecast_rain_mm.inspect}, temperature_c=#{temperature_c.inspect}, humidity_pct=#{humidity_pct.inspect}"
    end

    r = @rules

    if rainfall_today_mm > r.fetch(:rain_today_threshold_mm)
      return Result.new(coefficient: r.fetch(:rain_today_coefficient), reasons: ["rain_today_over_threshold"])
    end

    if forecast_rain_mm > r.fetch(:forecast_rain_threshold_mm)
      return Result.new(coefficient: r.fetch(:forecast_rain_coefficient), reasons: ["forecast_rain_over_threshold"])
    end

    if temperature_c > r.fetch(:hot_temperature_threshold_c) && humidity_pct < r.fetch(:hot_humidity_threshold_pct)
      return Result.new(coefficient: r.fetch(:hot_dry_coefficient), reasons: ["hot_and_dry"])
    end

    if temperature_c < r.fetch(:cold_temperature_threshold_c)
      return Result.new(coefficient: r.fetch(:cold_coefficient), reasons: ["cold"])
    end

    if humidity_pct > r.fetch(:high_humidity_threshold_pct)
      return Result.new(coefficient: r.fetch(:high_humidity_coefficient), reasons: ["high_humidity"])
    end

    Result.new(coefficient: r.fetch(:default_coefficient), reasons: ["standard"])
  end
end
