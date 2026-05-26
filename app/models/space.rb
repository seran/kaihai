class Space < ApplicationRecord
  enum :visibility, [ :open, :private ], default: :open, prefix: true

  belongs_to :creator, class_name: "User", optional: true

  has_many :subscriptions, dependent: :destroy
  has_many :subscribers,   through: :subscriptions, source: :user
  has_many :moderators,    -> { where(subscriptions: { role: Subscription.roles[:moderator] }) },
                           through: :subscriptions, source: :user
  has_many :requests, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :waves, class_name: "Wave", dependent: :destroy
  has_many :entries, dependent: :destroy

  normalizes :handle, with: ->(h) { h.strip.downcase }
  validates :name, presence: true, length: { maximum: 60 }
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..20 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers, and underscores" }
  validates :description, length: { maximum: 500 }, allow_blank: true

  scope :alphabetical, -> { order(:name) }

  def recent_subscriptions(within: 1.month)
    subscriptions.where("subscriptions.created_at >= ?", within.ago)
                 .includes(:user)
                 .order(created_at: :desc)
  end

  def self.suggest_handle(input)
    base = input.to_s.strip.downcase
                .gsub(/[^a-z0-9_]+/, "_")
                .gsub(/_+/, "_")
                .gsub(/\A_+|_+\z/, "")
    base = "space" if base.length < 3

    candidate = base[0, 20]
    return candidate unless exists?(handle: candidate)

    prefix = base[0, 15]
    10.times do
      suffixed = "#{prefix}_#{rand(1000..9999)}"
      return suffixed unless exists?(handle: suffixed)
    end

    "#{prefix}_#{SecureRandom.hex(2)}"
  end

  def subscriber?(user)
    return false unless user
    subscriptions.exists?(user_id: user.id)
  end

  def moderator?(user)
    return false unless user
    subscriptions.exists?(user_id: user.id, role: Subscription.roles[:moderator])
  end

  def member?(user)
    return false unless user
    subscriptions.exists?(user_id: user.id, role: Subscription.roles[:member])
  end

  def pending_request_for(user)
    return nil unless user
    requests.where(user: user, status: :pending).first
  end

  def to_param
    handle
  end
end
