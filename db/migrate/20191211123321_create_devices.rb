class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices, id: false, primary_key: :device_id do |t|
      t.belongs_to :user

      t.string :device_id, null: false
      t.string :device_type
      t.string :device_family
      t.string :device_model

      t.timestamps
      t.index :device_id, unique: true
    end
  end
end
