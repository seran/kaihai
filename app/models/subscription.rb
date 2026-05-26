class Subscription < ApplicationRecord
  enum :role, [ :member, :moderator ], default: :member

  belongs_to :space, counter_cache: :members_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :space_id }
end
