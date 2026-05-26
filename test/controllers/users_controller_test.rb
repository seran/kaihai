require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  test "edit renders the profile page" do
    get profile_path
    assert_response :success
    assert_select "h1", "Profile"
  end

  test "update profile via HTML form redirects with notice" do
    patch user_path, params: { user: { name: "New Name", handle: "newuser" } }
    assert_redirected_to profile_path
    @user.reload
    assert_equal "New Name", @user.name
    assert_equal "newuser",  @user.handle
  end

  test "update theme via JSON returns no_content" do
    patch user_path, params: { user: { theme: "warm-dark" } }, as: :json
    assert_response :no_content
    assert_equal "warm-dark", @user.reload.theme
  end

  test "update persists a valid time_zone" do
    patch user_path, params: { user: { time_zone: "America/Los_Angeles" } }
    assert_redirected_to profile_path
    assert_equal "America/Los_Angeles", @user.reload.time_zone
  end

  test "update rejects an invalid time_zone" do
    patch user_path, params: { user: { time_zone: "Mars/Olympus" } }
    assert_response :unprocessable_entity
    refute_equal "Mars/Olympus", @user.reload.time_zone
  end

  test "update with invalid params re-renders edit" do
    patch user_path, params: { user: { handle: "" } }
    assert_response :unprocessable_entity
    refute_equal "", @user.reload.handle
  end

  test "destroy with correct handle deletes the account and signs out" do
    user_id = @user.id
    delete user_path, params: { confirm_handle: @user.handle }
    assert_redirected_to new_session_path
    assert_nil User.find_by(id: user_id)
    assert_nil cookies[:session_id].presence
  end

  test "destroy with wrong handle does not delete" do
    delete user_path, params: { confirm_handle: "wrong-name" }
    assert_redirected_to profile_path
    assert User.exists?(@user.id)
  end
end
