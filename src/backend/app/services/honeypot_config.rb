# config/honeypot.yml を読み込む薄いローダー。
module HoneypotConfig
  CONFIG_PATH = Rails.root.join("config", "honeypot.yml")

  def self.load
    YAML.safe_load(ERB.new(CONFIG_PATH.read).result, symbolize_names: true)
  end
end
