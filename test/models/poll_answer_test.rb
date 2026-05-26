require "test_helper"

class PollAnswerTest < ActiveSupport::TestCase
  setup do
    @poll = Poll.create!(question: "?", poll_options: [ PollOption.new(body: "A"), PollOption.new(body: "B") ])
    Entry.create!(space: spaces(:open_lounge), author: users(:one), entryable: @poll)

    @other_poll = Poll.create!(question: "?", poll_options: [ PollOption.new(body: "X"), PollOption.new(body: "Y") ])
    Entry.create!(space: spaces(:open_lounge), author: users(:one), entryable: @other_poll)
  end

  test "a user can answer a poll once" do
    PollAnswer.create!(user: users(:two), poll: @poll, poll_option: @poll.poll_options.first)
    duplicate = PollAnswer.new(user: users(:two), poll: @poll, poll_option: @poll.poll_options.last)
    assert_not duplicate.valid?
  end

  test "rejects an answer whose option belongs to a different poll" do
    answer = PollAnswer.new(user: users(:two), poll: @poll, poll_option: @other_poll.poll_options.first)
    assert_not answer.valid?
    assert_includes answer.errors[:poll_option], "doesn't belong to this poll"
  end

  test "the same user can answer different polls" do
    PollAnswer.create!(user: users(:two), poll: @poll,       poll_option: @poll.poll_options.first)
    second = PollAnswer.new(user: users(:two), poll: @other_poll, poll_option: @other_poll.poll_options.first)
    assert_predicate second, :valid?
  end
end
