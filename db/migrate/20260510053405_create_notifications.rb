class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :recipient,  foreign_key: { to_table: :users }
      t.references :actor,      foreign_key: { to_table: :users }
      t.references :notifiable, polymorphic: true, null: false
      t.string     :kind,       null: false
      t.datetime   :read_at

      t.timestamps
    end
    add_index :notifications, [ :recipient_id, :read_at ]
    add_index :notifications, [ :recipient_id, :created_at ]
  end
end
