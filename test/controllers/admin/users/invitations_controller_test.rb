require "test_helper"

class Admin::Users::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @admin.update!(role: :admin)
    sign_in_as @admin
  end

  test "creates a pending invite and queues the invitation email" do
    assert_difference -> { User.count }, +1 do
      post admin_invitations_path, params: { user: { email_address: "new@example.com" } }
    end

    invitee = User.find_by(email_address: "new@example.com")
    assert_enqueued_email_with InvitationsMailer, :invite, args: [ invitee ]
    assert_predicate invitee, :pending_invitation?
    assert_equal @admin, invitee.invited_by
  end

  test "rejects invites for already-claimed accounts" do
    existing = users(:two)
    assert_no_difference -> { User.count } do
      post admin_invitations_path, params: { user: { email_address: existing.email_address } }
    end
    assert_redirected_to admin_users_path
  end

  test "non-admin gets forbidden" do
    sign_in_as users(:two)
    post admin_invitations_path, params: { user: { email_address: "blocked@example.com" } }
    assert_response :forbidden
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
