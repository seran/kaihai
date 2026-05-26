class Request < ApplicationRecord
  enum :status, [ :pending, :approved, :declined ], default: :pending

  belongs_to :space
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :user_id, uniqueness: { scope: :space_id, conditions: -> { where(status: :pending) },
                                    message: "already has a pending request for this space" },
            if: :pending?

  scope :pending_first, -> { order(Arel.sql("CASE status WHEN 0 THEN 0 ELSE 1 END"), created_at: :desc) }

  def approve!(by:)
    transaction do
      update!(status: :approved)
      space.subscriptions.find_or_create_by!(user: user)
      notifications.update_all(read_at: Time.current)
    end
  end

  def decline!(by:)
    transaction do
      update!(status: :declined)
      notifications.update_all(read_at: Time.current)
    end
  end
end
