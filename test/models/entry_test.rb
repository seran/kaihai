require "test_helper"

class EntryTest < ActiveSupport::TestCase
  setup do
    @space  = spaces(:open_lounge)
    @author = users(:one)
    @other  = users(:two)
  end

  test "is valid with a Post entryable" do
    entry = Entry.new(space: @space, author: @author, entryable: Post.new(body: "Hi"))
    assert_predicate entry, :valid?
  end

  test "is invalid without an entryable" do
    entry = Entry.new(space: @space, author: @author)
    assert_not entry.valid?
  end

  test "delegated_type accessors return the right subtype" do
    entry = Entry.create!(space: @space, author: @author, entryable: Post.new(body: "Hi"))
    assert_kind_of Post, entry.entryable
    assert_equal "Post", entry.entryable_type
  end

  test "destroying the entry destroys the entryable (dependent: :destroy)" do
    entry = Entry.create!(space: @space, author: @author, entryable: Post.new(body: "Hi"))
    post_id = entry.entryable_id
    entry.destroy!
    assert_not Post.exists?(post_id)
  end

  test "editable_by? — author and space moderator both qualify, others don't" do
    entry = Entry.create!(space: @space, author: @author, entryable: Post.new(body: "Hi"))
    assert entry.editable_by?(@author)
    assert_not entry.editable_by?(@other)
    assert_not entry.editable_by?(nil)
  end

  test "liked_by? and bookmarked_by? reflect interaction state" do
    entry = Entry.create!(space: @space, author: @author, entryable: Post.new(body: "Hi"))
    assert_not entry.liked_by?(@other)
    Like.create!(user: @other, likeable: entry)
    assert entry.liked_by?(@other)

    assert_not entry.bookmarked_by?(@other)
    Bookmark.create!(user: @other, entry: entry)
    assert entry.bookmarked_by?(@other)
  end
end
