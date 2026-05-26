require "test_helper"

class MagicLinksControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_magic_link_path
    assert_response :success
  end

  test "create" do
    post magic_links_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with SessionsMailer, :magic_link, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Sign-in link sent"
  end

  test "create for an unknown user redirects but sends no mail" do
    post magic_links_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Sign-in link sent"
  end

  test "create for a deactivated user redirects but sends no mail" do
    post magic_links_path, params: { email_address: users(:deactivated).email_address }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path
  end

  test "create for a blocked user redirects but sends no mail" do
    post magic_links_path, params: { email_address: users(:blocked).email_address }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path
  end

  test "show signs the user in with a valid token" do
    get magic_link_path(@user.generate_token_for(:magic_link))

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "show with invalid token redirects" do
    get magic_link_path("invalid-token")
    assert_redirected_to new_magic_link_path
    assert_nil cookies[:session_id]

    follow_redirect!
    assert_alert "invalid or has expired"
  end

  test "show with expired token redirects" do
    token = travel_to(1.hour.ago) { @user.generate_token_for(:magic_link) }

    get magic_link_path(token)

    assert_redirected_to new_magic_link_path
    assert_nil cookies[:session_id]
  end

  test "show with token invalidated by password change redirects" do
    token = @user.generate_token_for(:magic_link)
    @user.update_columns(password_digest: BCrypt::Password.create("new-password"))

    get magic_link_path(token)

    assert_redirected_to new_magic_link_path
    assert_nil cookies[:session_id]
  end

  test "show rejects a valid token for a deactivated user" do
    user = users(:deactivated)
    get magic_link_path(user.generate_token_for(:magic_link))

    assert_redirected_to new_magic_link_path
    assert_nil cookies[:session_id]
  end

  test "show rejects a valid token for a blocked user" do
    user = users(:blocked)
    get magic_link_path(user.generate_token_for(:magic_link))

    assert_redirected_to new_magic_link_path
    assert_nil cookies[:session_id]
  end

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end

    def assert_alert(text)
      assert_select "div", /#{text}/
    end
end
