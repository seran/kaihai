class Comment < ApplicationRecord
  belongs_to :entry, counter_cache: true, touch: true
  belongs_to :user

  has_many :likes, as: :likeable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2_000 }

  after_create_commit :notify_entry_author

  def editable_by?(other)
    other && (user_id == other.id || entry.space.moderator?(other))
  end

  def liked_by?(other)
    other && likes.exists?(user_id: other.id)
  end

  private
    def notify_entry_author
      return if user_id == entry.author_id
      Notification.create!(
        recipient:  entry.author,
        actor:      user,
        notifiable: self,
        kind:       "comment"
      )
    end
end
