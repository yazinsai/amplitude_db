class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices, id: false, primary_key: :device_id do |t|
      t.string :device_id, null: false
      t.string :device_type
      t.string :device_family
      t.string :device_model

      t.string :user_id

      t.timestamps
      t.index :device_id, unique: true
    end
    add_foreign_key :devices, :users, column: 'user_id', primary_key: 'user_id'
  end
end
