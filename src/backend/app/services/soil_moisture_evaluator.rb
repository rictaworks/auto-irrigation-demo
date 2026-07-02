# 土壌水分センサー値(0〜100%)を評価し、状態ラベルと灌水スコアを算出する。
class SoilMoistureEvaluator
  Result = Struct.new(:label, :score, keyword_init: true)

  class InvalidMoistureError < StandardError; end

  def initialize(thresholds: IrrigationRules.load.fetch(:soil_moisture).fetch(:thresholds))
    @thresholds = thresholds
  end

  def validate(moisture)
    moisture.is_a?(Numeric) && moisture.between?(0, 100)
  end

  def evaluate(moisture)
    raise InvalidMoistureError, "soil moisture must be within 0..100, got #{moisture.inspect}" unless validate(moisture)

    rule = @thresholds.find { |t| moisture <= t.fetch(:max_pct) }
    Result.new(label: rule.fetch(:label), score: rule.fetch(:score))
  end
end
