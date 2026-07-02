class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    # id は UUID v4 (TEXT) を採用し、オーナーキーとして使用する。
    create_table :sessions, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.datetime :last_active_at, null: false

      t.timestamps
    end
  end
end
