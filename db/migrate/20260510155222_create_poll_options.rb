class CreatePollOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :poll_options do |t|
      t.references :poll, null: false, foreign_key: true
      t.string     :body, null: false

      t.timestamps
    end
  end
end
