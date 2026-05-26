class Post < ApplicationRecord
  include Entryable

  validates :body, presence: true

  def searchable_body
    body
  end
end
