require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "is active by default" do
    assert_predicate User.new, :active?
  end

  test "rejects a new user with a blocked user's email_address" do
    blocked = users(:blocked)
    user = User.new(email_address: blocked.email_address, handle: "newuser", name: "New",
                    password: "password", password_confirmation: "password")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "waved? is false until a wave is sent and true after" do
    space = spaces(:open_lounge)
    from  = users(:one)
    to    = users(:two)

    assert_not from.waved?(to, in_space: space)

    Wave.create!(from_user: from, to_user: to, space: space)
    assert from.waved?(to, in_space: space)
  end

  test "suggest_handle slugifies and returns the input when available" do
    assert_equal "fresh_handle", User.suggest_handle("Fresh Handle")
  end

  test "suggest_handle appends a 4-digit suffix when the slug is taken" do
    suggestion = User.suggest_handle(users(:one).handle)
    assert_match(/\A#{Regexp.escape(users(:one).handle)}_\d{4}\z/, suggestion)
    assert_not User.exists?(handle: suggestion)
  end

  test "suggest_handle returns the input when except_user_id matches the current owner" do
    user = users(:one)
    assert_equal user.handle, User.suggest_handle(user.handle, except_user_id: user.id)
  end
end
