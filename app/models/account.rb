class Account < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }, allow_nil: true

  def self.singleton
    first || create!
  end

  def configured?
    name.present?
  end
end
