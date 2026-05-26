require "test_helper"

class LikeTest < ActiveSupport::TestCase
  setup do
    @user  = users(:one)
    @other = users(:two)
    @entry = Entry.create!(space: spaces(:open_lounge), author: @other, entryable: Post.new(body: "Hi"))
  end

  test "a user can like an entry once" do
    Like.create!(user: @user, likeable: @entry)
    duplicate = Like.new(user: @user, likeable: @entry)
    assert_not duplicate.valid?
  end

  test "two different users can each like the same entry" do
    Like.create!(user: @user,  likeable: @entry)
    second = Like.new(user: @other, likeable: @entry)
    assert_predicate second, :valid?
  end

  test "liking an entry increments its likes_count counter cache" do
    assert_difference -> { @entry.reload.likes_count }, +1 do
      Like.create!(user: @user, likeable: @entry)
    end
  end

  test "polymorphic — comment likes don't collide with entry likes" do
    comment = Comment.create!(entry: @entry, user: @other, body: "Cool")
    Like.create!(user: @user, likeable: @entry)
    second = Like.new(user: @user, likeable: comment)
    assert_predicate second, :valid?
  end

  test "liking an entry touches the entry's updated_at" do
    @entry.update_columns(updated_at: 1.hour.ago)
    before = @entry.reload.updated_at
    Like.create!(user: @user, likeable: @entry)
    assert_operator @entry.reload.updated_at, :>, before
  end

  test "liking a comment cascades a touch to the parent entry" do
    comment = Comment.create!(entry: @entry, user: @other, body: "Hi")
    @entry.update_columns(updated_at: 1.hour.ago)
    before = @entry.reload.updated_at
    Like.create!(user: @user, likeable: comment)
    assert_operator @entry.reload.updated_at, :>, before
  end
end
