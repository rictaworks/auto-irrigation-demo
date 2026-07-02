class SensorReading < ApplicationRecord
  belongs_to :session

  validates :soil_moisture_pct, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :rainfall_today_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :forecast_rain_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :temperature_c, numericality: true
  validates :humidity_pct, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :recorded_at, presence: true
end
