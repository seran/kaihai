require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one).tap { |u| u.update!(role: :admin) }
    @other = users(:two)
  end

  test "index lists users for admins" do
    sign_in_as @admin
    get admin_users_path
    assert_response :success
    assert_select "a[href=?]", admin_user_path(@other)
  end

  test "index filters by handle/name search" do
    sign_in_as @admin
    get admin_users_path, params: { q: "two" }
    assert_response :success
    assert_select "a[href=?]", admin_user_path(@other)
    assert_select "a[href=?]", admin_user_path(@admin), false
  end

  test "index filters by role" do
    sign_in_as @admin
    get admin_users_path, params: { role: "admin" }
    assert_response :success
    assert_select "a[href=?]", admin_user_path(@admin)
    assert_select "a[href=?]", admin_user_path(@other), false
  end

  test "index is forbidden to non-admins" do
    sign_in_as @other
    get admin_users_path
    assert_response :forbidden
  end

  test "show renders for admins" do
    sign_in_as @admin
    get admin_user_path(@other)
    assert_response :success
  end

  test "edit renders for admins" do
    sign_in_as @admin
    get edit_admin_user_path(@other)
    assert_response :success
  end

  test "update persists name, role, status changes" do
    sign_in_as @admin
    patch admin_user_path(@other), params: {
      user: { name: "Renamed", role: "admin", status: "deactivated" }
    }
    assert_redirected_to admin_user_path(@other)
    @other.reload
    assert_equal "Renamed",     @other.name
    assert_equal "admin",       @other.role
    assert_equal "deactivated", @other.status
  end

  test "update is forbidden to non-admins" do
    sign_in_as @other
    patch admin_user_path(@admin), params: { user: { name: "Hijack" } }
    assert_response :forbidden
    refute_equal "Hijack", @admin.reload.name
  end

  test "update rejects invalid params" do
    sign_in_as @admin
    patch admin_user_path(@other), params: { user: { handle: "" } }
    assert_response :unprocessable_entity
    refute_equal "", @other.reload.handle
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
