class Wave < ApplicationRecord
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user,   class_name: "User"
  belongs_to :space

  validates :from_user_id, uniqueness: { scope: %i[to_user_id space_id] }
  validate  :not_to_self

  after_create_commit :notify_recipient

  def reciprocal?
    self.class.where(from_user_id: to_user_id, to_user_id: from_user_id, space_id: space_id)
              .where("created_at < ?", created_at || Time.current)
              .exists?
  end

  private
    def not_to_self
      errors.add(:to_user_id, "can't wave at yourself") if from_user_id == to_user_id
    end

    def notify_recipient
      Notification.create!(recipient: to_user, actor: from_user, notifiable: self, kind: "wave")
    end
end
