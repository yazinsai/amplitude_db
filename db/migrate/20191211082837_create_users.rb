class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false, primary_key: :user_id do |t|
      t.string :user_id, null: false
      t.string :email
      t.string :ref

      t.timestamps
      t.index :user_id, unique: true
    end
  end
end
