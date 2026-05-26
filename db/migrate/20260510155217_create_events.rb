class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.text     :description
      t.datetime :starts_at, null: false
      t.string   :location

      t.timestamps
    end
    add_index :events, :starts_at
  end
end
