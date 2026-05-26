class Entry < ApplicationRecord
  include Searchable

  delegated_type :entryable, types: %w[ Post Event Poll ], dependent: :destroy

  belongs_to :space
  belongs_to :author, class_name: "User"

  has_many :comments,  dependent: :destroy
  has_many :likes,     as: :likeable, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  has_one :latest_comment, -> { order(created_at: :desc) }, class_name: "Comment", inverse_of: :entry

  validates :entryable, presence: true

  scope :newest_first, -> { order(created_at: :desc) }

  def self.matching(query, space:)
    fts = FtsQuery.build(query)
    return none if fts.blank?

    joins("JOIN entry_search ON entry_search.rowid = entries.id")
      .where("entry_search MATCH ?", fts)
      .where(space_id: space.id)
      .order(Arel.sql("entry_search.rank"))
  end

  def editable_by?(user)
    user && (author_id == user.id || space.moderator?(user))
  end

  def liked_by?(user)
    user && likes.exists?(user_id: user.id)
  end

  def bookmarked_by?(user)
    user && bookmarks.exists?(user_id: user.id)
  end

  def searchable_body
    entryable&.searchable_body
  end
end
