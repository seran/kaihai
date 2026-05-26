require "test_helper"

class WaveTest < ActiveSupport::TestCase
  setup do
    @space    = spaces(:open_lounge)
    @from     = users(:one)
    @to       = users(:two)
  end

  test "valid with distinct from_user, to_user, and space" do
    assert_predicate Wave.new(from_user: @from, to_user: @to, space: @space), :valid?
  end

  test "rejects waves to self" do
    wave = Wave.new(from_user: @from, to_user: @from, space: @space)
    assert_not wave.valid?
    assert_includes wave.errors[:to_user_id], "can't wave at yourself"
  end

  test "is unique per (from_user, to_user, space) tuple" do
    Wave.create!(from_user: @from, to_user: @to, space: @space)
    duplicate = Wave.new(from_user: @from, to_user: @to, space: @space)
    assert_not duplicate.valid?
  end

  test "same pair can wave in different spaces" do
    Wave.create!(from_user: @from, to_user: @to, space: @space)
    other = Wave.new(from_user: @from, to_user: @to, space: spaces(:private_garden))
    assert_predicate other, :valid?
  end
end
