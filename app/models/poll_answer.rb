class PollAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  belongs_to :poll_option

  validates :user_id, uniqueness: { scope: :poll_id }
  validate  :option_belongs_to_poll

  private
    def option_belongs_to_poll
      return unless poll_option && poll
      errors.add(:poll_option, "doesn't belong to this poll") if poll_option.poll_id != poll_id
    end
end
