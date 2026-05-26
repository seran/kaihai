require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "edit is accessible to admins" do
    sign_in_as users(:one).tap { |u| u.update!(role: :admin) }
    get edit_admin_account_path
    assert_response :success
  end

  test "edit is forbidden to non-admins" do
    sign_in_as users(:two)
    get edit_admin_account_path
    assert_response :forbidden
  end

  test "update persists account changes for admins" do
    sign_in_as users(:one).tap { |u| u.update!(role: :admin) }
    patch admin_account_path, params: { account: { name: "Renamed", tagline: "shhh" } }
    assert_redirected_to edit_admin_account_path
    assert_equal "Renamed", Account.singleton.name
    assert_equal "shhh",    Account.singleton.tagline
  end

  test "update is forbidden to non-admins" do
    sign_in_as users(:two)
    patch admin_account_path, params: { account: { name: "Hijack" } }
    assert_response :forbidden
    refute_equal "Hijack", Account.singleton.reload.name
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
