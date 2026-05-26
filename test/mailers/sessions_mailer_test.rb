require "test_helper"

class SessionsMailerTest < ActionMailer::TestCase
  test "magic_link" do
    user = User.take
    mail = SessionsMailer.magic_link(user)

    assert_equal "Your sign-in link", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_match %r{/magic_links/[^"\s]+}, mail.body.encoded
  end
end
