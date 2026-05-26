class CreateEntrySearch < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table "entry_search", "fts5", [ "body", "tokenize=porter" ]

    Entry.find_each(&:create_in_search_index)
  end

  def down
    drop_table "entry_search"
  end
end
