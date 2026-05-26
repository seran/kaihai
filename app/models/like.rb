class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: :likes_count, touch: true

  validates :user_id, uniqueness: { scope: %i[ likeable_type likeable_id ] }
end
