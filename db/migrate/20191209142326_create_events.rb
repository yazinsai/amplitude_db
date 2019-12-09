class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.bigint :event_id, null: false
      t.string :uuid
      t.string :user_id
      t.string :device_id
      t.string :email

      t.string :device_type

      t.string :event_type

      t.text :event_properties
      t.text :data

      t.string :country
      t.string :region
      t.string :city

      t.string :referrer

      t.datetime :event_time     

      t.timestamps
      t.index :event_id, unique: true
    end
  end
end
