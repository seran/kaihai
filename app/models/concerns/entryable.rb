module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true, dependent: :destroy, inverse_of: :entryable
  end
end
