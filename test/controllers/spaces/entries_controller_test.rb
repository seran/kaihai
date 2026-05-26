require "test_helper"

class Spaces::EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space     = spaces(:open_lounge)
    @moderator = users(:one) # already subscribed as moderator (fixture)
    @stranger  = users(:two) # not subscribed
    sign_in_as @moderator
  end

  test "subscriber can create a Post entry" do
    assert_difference -> { Entry.count }, +1 do
      assert_difference -> { Post.count }, +1 do
        post space_entries_path(@space, type: "Post"), params: { post: { body: "Hi everyone." } }
      end
    end
    entry = Entry.last
    assert_redirected_to space_entry_path(@space, entry)
    assert_equal @moderator, entry.author
    assert_kind_of Post, entry.entryable
  end

  test "subscriber can create an Event entry" do
    assert_difference -> { Entry.count }, +1 do
      post space_entries_path(@space, type: "Event"), params: {
        event: { description: "Picnic", starts_at: 1.day.from_now, location: "Park" }
      }
    end
    entry = Entry.last
    assert_kind_of Event, entry.entryable
  end

  test "subscriber can create a Poll entry with options" do
    assert_difference -> { Entry.count }, +1 do
      assert_difference -> { PollOption.count }, +2 do
        post space_entries_path(@space, type: "Poll"), params: {
          poll: {
            question: "Tea or coffee?",
            poll_options_attributes: { "0" => { body: "Tea" }, "1" => { body: "Coffee" } }
          }
        }
      end
    end
    entry = Entry.last
    assert_kind_of Poll, entry.entryable
    assert_equal 2, entry.entryable.poll_options.count
  end

  test "non-subscriber cannot create an entry" do
    sign_in_as @stranger
    assert_no_difference -> { Entry.count } do
      post space_entries_path(@space, type: "Post"), params: { post: { body: "Hello." } }
    end
    assert_response :forbidden
  end

  test "author can delete their own entry" do
    entry = build_post_entry(author: @moderator)
    assert_difference -> { Entry.count }, -1 do
      delete space_entry_path(@space, entry)
    end
  end

  test "non-author non-moderator cannot delete someone else's entry" do
    other = users(:two)
    @space.subscriptions.create!(user: other)
    entry = build_post_entry(author: @moderator)
    sign_in_as other
    assert_no_difference -> { Entry.count } do
      delete space_entry_path(@space, entry)
    end
    assert_response :forbidden
  end

  test "moderator can delete someone else's entry" do
    other = users(:two)
    @space.subscriptions.create!(user: other)
    entry = build_post_entry(author: other)
    assert_difference -> { Entry.count }, -1 do
      delete space_entry_path(@space, entry)
    end
  end

  private
    def sign_in_as(user)
      delete session_path
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    def build_post_entry(author:)
      Entry.create!(space: @space, author: author, entryable: Post.new(body: "Existing"))
    end
end
