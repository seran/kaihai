class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :space,  null: false, foreign_key: true
      t.references :user,   null: false, foreign_key: true
      t.integer    :status, null: false, default: 0

      t.timestamps
    end
    add_index :requests, [ :space_id, :user_id, :status ]
  end
end
