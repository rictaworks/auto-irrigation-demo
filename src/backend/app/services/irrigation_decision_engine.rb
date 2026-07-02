# 土壌スコア×天気係数から灌水要否レベル・推奨水量・実施タイミングを算出する。
class IrrigationDecisionEngine
  NeedResult = Struct.new(:level, :total_score, keyword_init: true)
  VolumeResult = Struct.new(:volume_l, keyword_init: true)
  ScheduleResult = Struct.new(:action, :recommended_hour, keyword_init: true)

  class InvalidSoilTypeError < StandardError; end

  def initialize(rules: IrrigationRules.load)
    @levels = rules.fetch(:decision).fetch(:levels)
    @water_volume = rules.fetch(:water_volume_l_per_m2)
    @schedule_rules = rules.fetch(:schedule)
  end

  def calculate_need(soil_score:, weather_coefficient:)
    total_score = soil_score * weather_coefficient
    level = @levels.find { |l| total_score >= l.fetch(:min_score) }.fetch(:key)
    NeedResult.new(level: level.to_s, total_score: total_score)
  end

  def calculate_volume(level:, area_m2:, soil_type:)
    table = @water_volume.fetch(level.to_sym) { raise ArgumentError, "unknown level: #{level}" }
    soil_key = soil_type.to_sym
    raise InvalidSoilTypeError, "unknown soil_type: #{soil_type}" unless table.key?(soil_key)

    VolumeResult.new(volume_l: table.fetch(soil_key) * area_m2)
  end

  def schedule(level:, current_hour_jst:, temperature_c:)
    case level.to_sym
    when :immediate
      schedule_immediate(current_hour_jst: current_hour_jst, temperature_c: temperature_c)
    when :recommended
      ScheduleResult.new(action: "next_morning", recommended_hour: @schedule_rules.fetch(:next_morning_start_hour))
    when :watch
      ScheduleResult.new(action: "reevaluate_tomorrow", recommended_hour: nil)
    when :none
      ScheduleResult.new(action: "skip", recommended_hour: nil)
    else
      raise ArgumentError, "unknown level: #{level}"
    end
  end

  private

  def schedule_immediate(current_hour_jst:, temperature_c:)
    r = @schedule_rules

    if current_hour_jst.between?(r.fetch(:hot_afternoon_start_hour), r.fetch(:hot_afternoon_end_hour)) &&
        temperature_c > r.fetch(:hot_afternoon_temperature_threshold_c)
      return ScheduleResult.new(action: "wait_until_evening", recommended_hour: r.fetch(:hot_afternoon_recommended_hour))
    end

    if night_hour?(current_hour_jst)
      return ScheduleResult.new(action: "emergency_confirm", recommended_hour: current_hour_jst)
    end

    ScheduleResult.new(action: "execute_now", recommended_hour: current_hour_jst)
  end

  def night_hour?(hour)
    r = @schedule_rules
    start_h = r.fetch(:night_start_hour)
    end_h = r.fetch(:night_end_hour)

    # 22:00〜5:00のように日をまたぐ範囲を扱う
    if start_h <= end_h
      hour.between?(start_h, end_h)
    else
      hour >= start_h || hour <= end_h
    end
  end
end
