class CreatePolls < ActiveRecord::Migration[8.1]
  def change
    create_table :polls do |t|
      t.text :question, null: false

      t.timestamps
    end
  end
end
