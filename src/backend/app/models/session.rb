# デモ版の認証なしオーナーキー。id は UUID v4 (SessionManager#generate_session_id で発行)。
class Session < ApplicationRecord
  has_many :field_settings, dependent: :destroy
  has_many :sensor_readings, dependent: :destroy
  has_many :irrigation_logs, dependent: :destroy

  validates :id, presence: true
  validates :last_active_at, presence: true
end
