class Notification < ApplicationRecord
  KINDS = %w[ comment wave space_request ].freeze

  belongs_to :recipient,  class_name: "User", optional: true
  belongs_to :actor,      class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true

  validates :kind, inclusion: { in: KINDS }

  scope :unread, -> { where(read_at: nil) }
  scope :for,    ->(user) { where(recipient: user) }

  after_create_commit :broadcast_sidebar
  after_update_commit :broadcast_sidebar, if: -> { saved_change_to_read_at? }
  after_destroy_commit :broadcast_sidebar

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def self.broadcast_sidebar_for(user)
    return unless user
    Turbo::StreamsChannel.broadcast_replace_to(
      [ user, :sidebar_notifications ],
      target:  "sidebar-notifications",
      partial: "shared/sidebar_notifications",
      locals:  { user: user }
    )
  end

  private
    def broadcast_sidebar
      self.class.broadcast_sidebar_for(recipient)
    end
end
