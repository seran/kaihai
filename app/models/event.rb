class Event < ApplicationRecord
  include Entryable

  has_many :event_responses, dependent: :destroy

  validates :starts_at, presence: true

  def response_for(user)
    return nil unless user
    event_responses.find_by(user_id: user.id)
  end

  def past?
    starts_at.present? && starts_at.past?
  end

  def searchable_body
    [ description, location ].compact_blank.join("\n")
  end
end
