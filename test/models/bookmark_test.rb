require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  setup do
    @user  = users(:one)
    @other = users(:two)
    @entry = Entry.create!(space: spaces(:open_lounge), author: @other, entryable: Post.new(body: "Hi"))
  end

  test "a user can bookmark an entry once" do
    Bookmark.create!(user: @user, entry: @entry)
    duplicate = Bookmark.new(user: @user, entry: @entry)
    assert_not duplicate.valid?
  end

  test "two different users can each bookmark the same entry" do
    Bookmark.create!(user: @user,  entry: @entry)
    second = Bookmark.new(user: @other, entry: @entry)
    assert_predicate second, :valid?
  end
end
