require "test_helper"

class EventResponseTest < ActiveSupport::TestCase
  setup do
    @event = Event.create!(starts_at: 1.day.from_now, location: "Park")
    Entry.create!(space: spaces(:open_lounge), author: users(:one), entryable: @event)
  end

  test "default response is :going" do
    response = EventResponse.create!(event: @event, user: users(:two))
    assert response.response_going?
  end

  test "user can have only one response per event" do
    EventResponse.create!(event: @event, user: users(:two), response: :going)
    duplicate = EventResponse.new(event: @event, user: users(:two), response: :maybe)
    assert_not duplicate.valid?
  end

  test "all three response values are accepted" do
    %i[ going not_going maybe ].each do |value|
      response = EventResponse.new(event: @event, user: users(:one), response: value)
      assert_predicate response, :valid?, "expected :#{value} to be valid"
    end
  end
end
