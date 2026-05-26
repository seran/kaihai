require "test_helper"

class InvitationsMailerTest < ActionMailer::TestCase
  test "invite" do
    user = User.create!(email_address: "newcomer@example.com",
                        invited_at:    Time.current,
                        invited_by:    users(:one))
    mail = InvitationsMailer.invite(user)

    assert_equal [ "newcomer@example.com" ], mail.to
    assert_match "invited", mail.subject.downcase
    assert_match "Set up your account", mail.body.encoded
    assert_match "/invitations/", mail.body.encoded
  end
end
