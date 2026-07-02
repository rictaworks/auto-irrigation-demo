class CreateIrrigationLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :irrigation_logs do |t|
      t.references :session, type: :string, null: false, foreign_key: true
      t.string :decision, null: false
      t.float :soil_moisture, null: false
      t.float :weather_coeff, null: false
      t.float :total_score, null: false
      t.float :recommended_l, null: false
      t.string :action_taken, null: false
      t.datetime :executed_at, null: false

      t.timestamps
    end
  end
end
