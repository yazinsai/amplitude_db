class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :uuid, null: false
      t.string :device_id, null: false

      t.string :event_type

      t.json :event_properties
      t.json :user_properties
      t.json :data

      t.string :country
      t.string :region
      t.string :city

      t.string :referrer

      t.datetime :event_time     

      t.timestamps
      t.index :uuid, unique: true
    end
    add_foreign_key :events, :devices, column: 'device_id', primary_key: 'device_id'
  end
end
