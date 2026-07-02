class CreateFieldSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :field_settings do |t|
      t.references :session, type: :string, null: false, foreign_key: true
      t.float :area_m2, null: false
      t.string :soil_type, null: false

      t.timestamps
    end
  end
end
