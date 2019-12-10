class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.bigint :event_id
      t.string :uuid, null: false
      t.string :user_id
      t.string :device_id
      t.string :email

      t.string :device_type

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
  end
end
