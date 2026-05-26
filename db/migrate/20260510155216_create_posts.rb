class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.text :body, null: false

      t.timestamps
    end
  end
end
