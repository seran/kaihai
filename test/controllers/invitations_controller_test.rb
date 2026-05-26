require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invitee = User.create!(email_address: "newcomer@example.com",
                            invited_at:    Time.current,
                            invited_by:    users(:one))
    @token = @invitee.generate_token_for(:invitation)
  end

  test "edit renders the accept form for a valid token" do
    get edit_invitation_path(@token)
    assert_response :success
    assert_match "newcomer@example.com", @response.body
  end

  test "edit redirects when token is invalid" do
    get edit_invitation_path("not-a-real-token")
    assert_redirected_to new_session_path
  end

  test "update claims the account, signs in, and clears invited_at" do
    patch invitation_path(@token), params: {
      user: {
        name:                   "Newcomer",
        handle:                 "newcomer",
        password:               "secret123",
        password_confirmation:  "secret123"
      }
    }
    assert_redirected_to root_path

    @invitee.reload
    assert_predicate @invitee, :claimed?
    assert_nil @invitee.invited_at
    assert_equal "newcomer", @invitee.handle
    assert @invitee.authenticate("secret123")
  end

  test "update with mismatched passwords re-renders" do
    patch invitation_path(@token), params: {
      user: {
        name:                   "Newcomer",
        handle:                 "newcomer",
        password:               "secret123",
        password_confirmation:  "different"
      }
    }
    assert_response :unprocessable_entity
    assert_not @invitee.reload.claimed?
  end

  test "token can only be used once — second attempt is rejected" do
    patch invitation_path(@token), params: {
      user: { name: "Newcomer", handle: "newcomer",
              password: "secret123", password_confirmation: "secret123" }
    }
    delete session_path # sign out

    get edit_invitation_path(@token)
    assert_redirected_to new_session_path
  end
end
