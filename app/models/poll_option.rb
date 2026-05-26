class PollOption < ApplicationRecord
  belongs_to :poll, inverse_of: :poll_options, touch: true

  has_many :poll_answers, dependent: :destroy

  validates :body, presence: true, length: { maximum: 100 }
end
