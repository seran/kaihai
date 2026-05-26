class AddAdditionalFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column    :users, :name,       :string
    add_column    :users, :handle,     :string
    add_column    :users, :role,       :integer, default: 0
    add_column    :users, :status,     :integer, default: 0, null: false
    add_column    :users, :theme,      :string,  default: "warm-light", null: false
    add_column    :users, :accent,     :string,  default: "blue", null: false
    add_column    :users, :time_zone,  :string,  default: "UTC", null: false
    add_column    :users, :invited_at, :datetime
    add_reference :users, :invited_by, foreign_key: { to_table: :users }
    add_index     :users, :role
    add_index     :users, :status
    add_index     :users, :handle, unique: true
  end
end
