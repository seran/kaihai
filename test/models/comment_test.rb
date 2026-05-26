require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @space  = spaces(:open_lounge)
    @entry  = Entry.create!(space: @space, author: users(:one), entryable: Post.new(body: "Hi"))
  end

  test "creating a comment touches the entry's updated_at" do
    @entry.update_columns(updated_at: 1.hour.ago)
    before = @entry.reload.updated_at
    Comment.create!(entry: @entry, user: users(:two), body: "Cool")
    assert_operator @entry.reload.updated_at, :>, before
  end
end
