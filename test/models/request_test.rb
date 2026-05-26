require "test_helper"

class RequestTest < ActiveSupport::TestCase
  setup do
    @request = requests(:one_pending_for_garden)
    @space   = @request.space
    @user    = @request.user
    @mod     = users(:two)
  end

  test "approve! creates a subscription and marks status approved" do
    assert_difference -> { @space.subscriptions.count }, +1 do
      @request.approve!(by: @mod)
    end
    assert_predicate @request.reload, :approved?
    assert @space.subscriber?(@user)
  end

  test "decline! marks status declined and creates no subscription" do
    assert_no_difference -> { @space.subscriptions.count } do
      @request.decline!(by: @mod)
    end
    assert_predicate @request.reload, :declined?
  end

  test "duplicate pending request is invalid" do
    duplicate = Request.new(space: @space, user: @user, status: :pending)
    assert_not duplicate.valid?
  end
end
