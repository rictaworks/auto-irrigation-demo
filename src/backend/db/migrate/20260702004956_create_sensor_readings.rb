class CreateSensorReadings < ActiveRecord::Migration[7.2]
  def change
    create_table :sensor_readings do |t|
      t.references :session, type: :string, null: false, foreign_key: true
      t.float :soil_moisture_pct, null: false
      t.float :rainfall_today_mm, null: false
      t.float :forecast_rain_mm, null: false
      t.float :temperature_c, null: false
      t.float :humidity_pct, null: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end
  end
end
