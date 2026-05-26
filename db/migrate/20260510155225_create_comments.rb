class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :entry,       null: false, foreign_key: true
      t.references :user,        null: false, foreign_key: true
      t.text       :body,        null: false
      t.integer    :likes_count, null: false, default: 0

      t.timestamps
    end
    add_index :comments, %i[ entry_id created_at ]
  end
end
