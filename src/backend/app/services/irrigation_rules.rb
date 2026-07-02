# config/irrigation_rules.yml を読み込む薄いローダー。
# 判定閾値・係数をコードに直書きしないためのアクセスポイント。
module IrrigationRules
  CONFIG_PATH = Rails.root.join("config", "irrigation_rules.yml")

  def self.load
    YAML.safe_load(ERB.new(CONFIG_PATH.read).result, permitted_classes: [Symbol], symbolize_names: true)
  end
end
