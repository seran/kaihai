require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  setup do
    @space = spaces(:open_lounge)
    @user  = users(:two)
    @mod   = users(:one)
  end

  test "valid with required attributes" do
    s = Space.new(name: "Test", handle: "test_room", visibility: :open)
    assert_predicate s, :valid?
  end

  test "requires unique handle" do
    s = Space.new(name: "Other", handle: @space.handle, visibility: :open)
    assert_not s.valid?
    assert_includes s.errors[:handle], "has already been taken"
  end

  test "rejects invalid handle format" do
    s = Space.new(name: "Bad", handle: "no spaces", visibility: :open)
    assert_not s.valid?
  end

  test "subscriber? reflects subscription" do
    assert @space.subscriber?(@mod)
    assert_not @space.subscriber?(@user)
  end

  test "moderator? returns true only for moderators" do
    assert @space.moderator?(@mod)
    assert_not @space.moderator?(@user)
  end

  test "members_count is incremented when a subscription is created" do
    assert_difference -> { @space.reload.members_count }, +1 do
      @space.subscriptions.create!(user: @user)
    end
  end

  test "members_count is decremented when a subscription is destroyed" do
    @space.subscriptions.create!(user: @user)
    assert_difference -> { @space.reload.members_count }, -1 do
      @space.subscriptions.find_by(user: @user).destroy
    end
  end

  test "suggest_handle slugifies and returns the input when available" do
    assert_equal "fresh_room", Space.suggest_handle("Fresh Room")
  end

  test "suggest_handle appends a 4-digit suffix when the slug is taken" do
    suggestion = Space.suggest_handle(@space.handle)
    assert_match(/\A#{Regexp.escape(@space.handle)}_\d{4}\z/, suggestion)
    assert_not Space.exists?(handle: suggestion)
  end

  test "suggest_handle falls back to a default base for short input" do
    assert_equal "space", Space.suggest_handle("a")
  end
end
