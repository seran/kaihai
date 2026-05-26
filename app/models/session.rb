class Session < ApplicationRecord
  belongs_to :user

  scope :for_active_user, -> { joins(:user).merge(User.active) }
end
