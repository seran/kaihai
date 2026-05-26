class User < ApplicationRecord
  THEMES  = %w[ warm-light cool-light pure-white warm-dark cool-dark pure-black ].freeze
  ACCENTS = %w[ blue orange yellow amber emerald violet ].freeze

  has_secure_password validations: false
  has_many :sessions, dependent: :destroy
  has_many :notifications,        foreign_key: :recipient_id, dependent: :destroy
  has_many :notifications_caused, class_name: "Notification", foreign_key: :actor_id, dependent: :nullify
  has_many :subscriptions, dependent: :destroy
  has_many :spaces, through: :subscriptions
  has_many :created_spaces, class_name: "Space", foreign_key: :creator_id, dependent: :nullify, inverse_of: :creator
  has_many :requests, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_spaces, through: :favorites, source: :space
  has_many :waves_sent,     class_name: "Wave", foreign_key: :from_user_id, dependent: :destroy, inverse_of: :from_user
  has_many :waves_received, class_name: "Wave", foreign_key: :to_user_id,   dependent: :destroy, inverse_of: :to_user
  belongs_to :invited_by, class_name: "User", optional: true
  has_many   :invitees,   class_name: "User", foreign_key: :invited_by_id, dependent: :nullify, inverse_of: :invited_by
  has_many :entries,    foreign_key: :author_id, class_name: "Entry", dependent: :destroy, inverse_of: :author
  has_many :comments,   dependent: :destroy
  has_many :likes,      dependent: :destroy
  has_many :bookmarks,  dependent: :destroy
  has_many :bookmarked_entries, through: :bookmarks, source: :entry
  has_many :event_responses, dependent: :destroy
  has_many :poll_answers,    dependent: :destroy

  generates_token_for :magic_link, expires_in: 15.minutes do
    password_digest&.last(10)
  end

  generates_token_for :invitation, expires_in: 24.hours do
    password_digest # nil while pending → token invalidates the moment they claim
  end

  enum :role, [ :user, :admin ], default: :user
  enum :status, [ :active, :deactivated, :blocked ], default: :active
  normalizes :handle, with: ->(e) { e&.strip&.downcase }
  validates :handle, uniqueness: { case_sensitive: true, allow_nil: true }
  validates :handle, presence: true, length: { in: 3..20 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only lowercase letters, numbers, and underscores" },
            unless: :pending_invitation?
  validates :name, presence: true, unless: :pending_invitation?
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :theme,     inclusion: { in: THEMES }
  validates :accent,    inclusion: { in: ACCENTS }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) | ActiveSupport::TimeZone::MAPPING.values }
  validates :password,  length: { maximum: 72 }, allow_blank: true, confirmation: true
  validate  :password_or_invitation_required

  def pending_invitation?
    invited_at.present? && password_digest.blank?
  end

  def claimed?
    password_digest.present?
  end

  def subscription_for(space)
    subscriptions.find_by(space_id: space.id)
  end

  def can_manage_space?(space)
    admin? || space.moderator?(self)
  end

  def can_post_in?(space)
    space.subscriber?(self)
  end

  def favorited?(space)
    favorites.exists?(space_id: space.id)
  end

  def waved?(user, in_space:)
    waves_sent.exists?(to_user_id: user.id, space_id: in_space.id)
  end

  def self.suggest_handle(input, except_user_id: nil)
    base = input.to_s.strip.downcase
                .gsub(/[^a-z0-9_]+/, "_")
                .gsub(/_+/, "_")
                .gsub(/\A_+|_+\z/, "")
    base = "user" if base.length < 3

    candidate = base[0, 20]
    return candidate unless handle_taken?(candidate, except_user_id)

    prefix = base[0, 15]
    10.times do
      suffixed = "#{prefix}_#{rand(1000..9999)}"
      return suffixed unless handle_taken?(suffixed, except_user_id)
    end

    "#{prefix}_#{SecureRandom.hex(2)}"
  end

  def self.handle_taken?(handle, except_id = nil)
    scope = where(handle: handle)
    scope = scope.where.not(id: except_id) if except_id
    scope.exists?
  end
  private_class_method :handle_taken?

  private
    def password_or_invitation_required
      return if password_digest.present? || invited_at.present?
      errors.add(:password, "can't be blank")
    end
end
