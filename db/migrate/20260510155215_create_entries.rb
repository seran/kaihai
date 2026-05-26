class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.references :space,  null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string     :entryable_type, null: false
      t.integer    :entryable_id,   null: false
      t.integer    :comments_count, null: false, default: 0
      t.integer    :likes_count,    null: false, default: 0

      t.timestamps
    end
    add_index :entries, %i[ entryable_type entryable_id ], unique: true
    add_index :entries, %i[ space_id created_at ]
  end
end
