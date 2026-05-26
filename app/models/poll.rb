class Poll < ApplicationRecord
  include Entryable

  has_many :poll_options, -> { order(:id) }, dependent: :destroy, inverse_of: :poll
  has_many :poll_answers, dependent: :destroy

  accepts_nested_attributes_for :poll_options, reject_if: ->(attrs) { attrs[:body].blank? }, allow_destroy: true

  validates :question, presence: true
  validate  :enough_options
  validate  :options_frozen_after_first_answer, on: :update

  def answered?
    poll_answers.exists?
  end

  def answer_for(user)
    return nil unless user
    poll_answers.find_by(user_id: user.id)
  end

  def searchable_body
    [ question, description, poll_options.map(&:body).join("\n") ].compact_blank.join("\n")
  end

  private
    def enough_options
      live = poll_options.reject(&:marked_for_destruction?)
      errors.add(:base, "needs at least 2 options")  if live.size < 2
      errors.add(:base, "can't have more than 10 options") if live.size > 10
    end

    def options_frozen_after_first_answer
      return unless answered?
      return unless poll_options.any? { |o| o.changed? || o.marked_for_destruction? || o.new_record? }
      errors.add(:base, "options can't change once answers exist")
    end
end
