class CreatePollAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :poll_answers do |t|
      t.references :user,        null: false, foreign_key: true
      t.references :poll,        null: false, foreign_key: true
      t.references :poll_option, null: false, foreign_key: true

      t.timestamps
    end
    add_index :poll_answers, %i[ user_id poll_id ], unique: true
  end
end
