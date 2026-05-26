class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :space, null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.integer    :role,  null: false, default: 0

      t.timestamps
    end
    add_index :subscriptions, [ :space_id, :user_id ], unique: true
  end
end
