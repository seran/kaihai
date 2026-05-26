class EventResponse < ApplicationRecord
  RESPONSES = %i[ going not_going maybe ].freeze

  enum :response, RESPONSES, default: :going, prefix: true

  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id }
end
