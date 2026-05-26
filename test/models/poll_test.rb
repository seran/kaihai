require "test_helper"

class PollTest < ActiveSupport::TestCase
  setup do
    @space  = spaces(:open_lounge)
    @author = users(:one)
  end

  test "is valid with at least 2 options" do
    poll = Poll.new(question: "Q?", poll_options: [ PollOption.new(body: "A"), PollOption.new(body: "B") ])
    assert_predicate poll, :valid?
  end

  test "is invalid with only 1 option" do
    poll = Poll.new(question: "Q?", poll_options: [ PollOption.new(body: "A") ])
    assert_not poll.valid?
  end

  test "is invalid with more than 10 options" do
    options = Array.new(11) { |i| PollOption.new(body: "Opt #{i}") }
    poll    = Poll.new(question: "Q?", poll_options: options)
    assert_not poll.valid?
  end

  test "options can't change once an answer exists" do
    poll = create_published_poll
    PollAnswer.create!(user: users(:two), poll: poll, poll_option: poll.poll_options.first)

    poll.poll_options.first.body = "Changed"
    assert_not poll.valid?
  end

  test "answered? flips after a poll_answer is created" do
    poll = create_published_poll
    assert_not poll.answered?
    PollAnswer.create!(user: users(:two), poll: poll, poll_option: poll.poll_options.first)
    assert poll.answered?
  end

  private
    def create_published_poll
      poll = Poll.create!(question: "Q?", poll_options: [ PollOption.new(body: "A"), PollOption.new(body: "B") ])
      Entry.create!(space: @space, author: @author, entryable: poll)
      poll
    end
end
