class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :amplitude_user_id, null: false
      t.string :email
      t.string :ref

      t.timestamps
      t.index :amplitude_user_id, unique: true
    end
  end
end
