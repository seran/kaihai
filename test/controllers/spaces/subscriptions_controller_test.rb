require "test_helper"

class Spaces::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user   = users(:two)
    @open   = spaces(:open_lounge)
    @closed = spaces(:private_garden)
    sign_in_as @user
  end

  test "joining an open space subscribes the user" do
    assert_difference -> { Subscription.count }, +1 do
      post space_subscription_path(@open)
    end
    assert @open.subscriber?(@user)
  end

  test "leaving an open space unsubscribes the user" do
    @open.subscriptions.create!(user: @user)
    assert_difference -> { Subscription.count }, -1 do
      delete space_subscription_path(@open)
    end
  end

  test "joining a private space directly is forbidden" do
    applicant = users(:one)
    sign_in_as applicant
    post space_subscription_path(@closed)
    assert_response :forbidden
    assert_not @closed.subscriber?(applicant)
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
