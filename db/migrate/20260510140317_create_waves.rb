class CreateWaves < ActiveRecord::Migration[8.1]
  def change
    create_table :waves do |t|
      t.references :from_user, null: false, foreign_key: { to_table: :users }
      t.references :to_user,   null: false, foreign_key: { to_table: :users }
      t.references :space,     null: false, foreign_key: true

      t.timestamps
    end

    add_index :waves, %i[from_user_id to_user_id space_id], unique: true
  end
end
