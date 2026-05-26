class CreateEventResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :event_responses do |t|
      t.references :event,    null: false, foreign_key: true
      t.references :user,     null: false, foreign_key: true
      t.integer    :response, null: false, default: 0

      t.timestamps
    end
    add_index :event_responses, %i[ event_id user_id ], unique: true
  end
end
