# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_07_02_004958) do
  create_table "field_settings", force: :cascade do |t|
    t.string "session_id", null: false
    t.float "area_m2", null: false
    t.string "soil_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_field_settings_on_session_id"
  end

  create_table "irrigation_logs", force: :cascade do |t|
    t.string "session_id", null: false
    t.string "decision", null: false
    t.float "soil_moisture", null: false
    t.float "weather_coeff", null: false
    t.float "total_score", null: false
    t.float "recommended_l", null: false
    t.string "action_taken", null: false
    t.datetime "executed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_irrigation_logs_on_session_id"
  end

  create_table "sensor_readings", force: :cascade do |t|
    t.string "session_id", null: false
    t.float "soil_moisture_pct", null: false
    t.float "rainfall_today_mm", null: false
    t.float "forecast_rain_mm", null: false
    t.float "temperature_c", null: false
    t.float "humidity_pct", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sensor_readings_on_session_id"
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "last_active_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "field_settings", "sessions"
  add_foreign_key "irrigation_logs", "sessions"
  add_foreign_key "sensor_readings", "sessions"
end
