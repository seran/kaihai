require "test_helper"

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  test "update with correct current password changes the password" do
    patch user_password_path, params: {
      current_password: "password",
      password: "newpassword",
      password_confirmation: "newpassword"
    }
    assert_redirected_to profile_path
    assert @user.reload.authenticate("newpassword")
  end

  test "update rejects wrong current password" do
    patch user_password_path, params: {
      current_password: "wrong",
      password: "newpassword",
      password_confirmation: "newpassword"
    }
    assert_redirected_to profile_path
    assert @user.reload.authenticate("password")
  end

  test "update rejects mismatched confirmation" do
    patch user_password_path, params: {
      current_password: "password",
      password: "newpassword",
      password_confirmation: "different"
    }
    assert_redirected_to profile_path
    assert @user.reload.authenticate("password")
  end
end
