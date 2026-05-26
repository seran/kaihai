require "test_helper"

class SetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Account.singleton.update!(name: nil, tagline: nil)
  end

  test "new renders the wizard when account is unconfigured" do
    get setup_path
    assert_response :success
    assert_select "h1", "Welcome."
  end

  test "new redirects to root when already configured" do
    Account.singleton.update!(name: "Already Set")
    get setup_path
    assert_redirected_to root_path
  end

  test "create persists account, creates admin, signs in, redirects" do
    assert_difference -> { User.count } => 1 do
      post setup_path, params: {
        account: { name: "Hello", tagline: "tiny" },
        user: {
          name: "Owner",
          handle: "owner",
          email_address: "owner@example.com",
          password: "secret123",
          password_confirmation: "secret123"
        }
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id].present?
    assert_equal "Hello", Account.singleton.name
    user = User.find_by(email_address: "owner@example.com")
    assert user.admin?
  end

  test "create re-renders wizard on validation error" do
    post setup_path, params: {
      account: { name: "" },
      user:    { name: "", handle: "x", email_address: "bad", password: "p", password_confirmation: "z" }
    }
    assert_response :unprocessable_entity
    assert_nil cookies[:session_id].presence
    assert_nil Account.singleton.reload.name
  end

  test "authenticated routes redirect to setup when account is unconfigured" do
    get root_path
    assert_redirected_to setup_path
  end
end
