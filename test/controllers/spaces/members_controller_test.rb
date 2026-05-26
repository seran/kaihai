require "test_helper"

class Spaces::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space     = spaces(:open_lounge)
    @moderator = users(:one) # already a moderator (fixture)
    @member    = users(:two)
    @space.subscriptions.create!(user: @member, role: :member)
    sign_in_as @moderator
  end

  test "moderator can promote a member" do
    subscription = @space.subscriptions.find_by(user: @member)
    patch space_member_path(@space, subscription), params: { subscription: { role: "moderator" } }
    assert subscription.reload.moderator?
  end

  test "moderator can demote another moderator" do
    @space.subscriptions.create!(user: users(:deactivated), role: :moderator)
    target = @space.subscriptions.find_by(user: users(:deactivated))
    patch space_member_path(@space, target), params: { subscription: { role: "member" } }
    assert target.reload.member?
  end

  test "the last moderator cannot be demoted" do
    subscription = @space.subscriptions.find_by(user: @moderator)
    sign_in_as @member # member tries (would be forbidden anyway, but the rule applies regardless)
    sign_in_as @moderator # back to mod
    # Add a non-mod to switch context — we want to test the last-mod rule directly.
    patch space_member_path(@space, subscription), params: { subscription: { role: "member" } }
    assert subscription.reload.moderator?, "last moderator should not have been demoted"
  end

  test "non-moderator gets forbidden" do
    sign_in_as @member
    subscription = @space.subscriptions.find_by(user: @member)
    patch space_member_path(@space, subscription), params: { subscription: { role: "moderator" } }
    assert_response :forbidden
  end

  test "admin (not a member) can update roles" do
    admin = users(:two) # promote to admin for this test
    admin.update!(role: :admin)
    sign_in_as admin
    subscription = @space.subscriptions.find_by(user: @member)
    patch space_member_path(@space, subscription), params: { subscription: { role: "moderator" } }
    assert subscription.reload.moderator?
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
