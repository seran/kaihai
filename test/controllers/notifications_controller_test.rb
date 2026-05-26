require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  test "index renders the current user's notifications" do
    get notifications_path
    assert_response :success
    assert_select "h1", "Notifications"
  end

  test "index requires authentication" do
    delete session_path
    get notifications_path
    assert_redirected_to new_session_path
  end

  test "index lists only the current user's notifications" do
    other = users(:two)
    Notification.create!(recipient: other, actor: @user, notifiable: other, kind: "wave")
    get notifications_path
    assert_select "ul.divide-y > li", count: @user.notifications.count
  end

  test "patch read_status marks every unread notification as read" do
    Notification.create!(recipient: @user, actor: users(:two), notifiable: users(:two), kind: "comment")
    assert @user.notifications.unread.any?

    patch read_status_path
    assert_redirected_to notifications_path
    assert_empty @user.notifications.reload.unread
  end
end
