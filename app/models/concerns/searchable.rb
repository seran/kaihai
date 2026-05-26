module Searchable
  extend ActiveSupport::Concern

  included do
    after_create_commit  :create_in_search_index
    after_update_commit  :update_in_search_index
    after_touch          :update_in_search_index
    after_destroy_commit :remove_from_search_index
  end

  def create_in_search_index
    body = searchable_body
    return if body.blank?

    execute_sql_with_binds "INSERT INTO entry_search (rowid, body) VALUES (?, ?)", id, body
  end

  def update_in_search_index
    remove_from_search_index
    create_in_search_index
  end

  def remove_from_search_index
    execute_sql_with_binds "DELETE FROM entry_search WHERE rowid = ?", id
  end

  private
    def execute_sql_with_binds(*statement)
      self.class.connection.execute self.class.sanitize_sql(statement)
    end
end
