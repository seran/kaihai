require "test_helper"

class Spaces::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space    = spaces(:open_lounge)
    @author   = users(:one)
    @commenter = users(:two)
    @space.subscriptions.create!(user: @commenter)
    @entry = Entry.create!(space: @space, author: @author, entryable: Post.new(body: "Hello"))
  end

  test "subscriber can post a comment and the entry author gets notified" do
    sign_in_as @commenter
    assert_difference -> { Comment.count }, +1 do
      assert_difference -> { Notification.where(recipient: @author, kind: "comment").count }, +1 do
        post space_entry_comments_path(@space, @entry), params: { comment: { body: "Hi" } }
      end
    end
  end

  test "self-comment doesn't notify the author" do
    sign_in_as @author
    assert_no_difference -> { Notification.where(recipient: @author, kind: "comment").count } do
      post space_entry_comments_path(@space, @entry), params: { comment: { body: "Self" } }
    end
  end

  private
    def sign_in_as(user)
      delete session_path
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
