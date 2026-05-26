class CreateSpaces < ActiveRecord::Migration[8.1]
  def change
    create_table :spaces do |t|
      t.string     :name,          null: false
      t.string     :handle,        null: false
      t.text       :description
      t.integer    :visibility,    null: false, default: 0
      t.integer    :members_count, null: false, default: 0
      t.references :creator,       foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :spaces, :handle,     unique: true
    add_index :spaces, :visibility
  end
end
