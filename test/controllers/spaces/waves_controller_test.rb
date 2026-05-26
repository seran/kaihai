require "test_helper"

class Spaces::WavesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @waver = users(:one)
    @other = users(:two)
    @space = spaces(:open_lounge)
    sign_in_as @waver
  end

  test "creates a wave from current user to the target user" do
    assert_difference -> { Wave.count }, +1 do
      post space_waves_path(@space, to_user_id: @other.id)
    end
    assert @waver.waved?(@other, in_space: @space)
  end

  test "creating a wave queues a notification for the recipient" do
    assert_difference -> { Notification.where(recipient: @other, kind: "wave").count }, +1 do
      post space_waves_path(@space, to_user_id: @other.id)
    end
  end

  test "duplicate wave attempts do not create extra notifications" do
    Wave.create!(from_user: @waver, to_user: @other, space: @space)
    assert_no_difference -> { Notification.where(recipient: @other, kind: "wave").count } do
      post space_waves_path(@space, to_user_id: @other.id)
    end
  end

  test "waving back marks the originating notifications as read" do
    inbound = notifications(:unread_wave) # recipient=@waver, actor=@other, kind=wave
    assert_not inbound.read?

    post space_waves_path(@space, to_user_id: @other.id)
    assert inbound.reload.read?
  end

  test "is idempotent — a second submission does not create a duplicate" do
    Wave.create!(from_user: @waver, to_user: @other, space: @space)
    assert_no_difference -> { Wave.count } do
      post space_waves_path(@space, to_user_id: @other.id)
    end
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
