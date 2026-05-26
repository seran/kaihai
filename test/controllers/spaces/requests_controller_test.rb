require "test_helper"

class Spaces::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @applicant = users(:one)
    @mod       = users(:two)
    @closed    = spaces(:private_garden)
  end

  test "requesting to join a private space notifies all moderators" do
    sign_in_as @applicant
    # remove existing fixture request so create works
    @closed.requests.destroy_all

    assert_difference -> { Notification.where(kind: "space_request").count }, +1 do
      post space_requests_path(@closed)
    end
    request = @closed.requests.pending.find_by(user: @applicant)
    assert_not_nil request
    assert_equal @mod, Notification.last.recipient
  end

  test "moderator can approve a pending request" do
    sign_in_as @mod
    request = requests(:one_pending_for_garden)

    assert_difference -> { Subscription.count }, +1 do
      patch space_request_path(@closed, request, decision: "approve")
    end
    assert_predicate request.reload, :approved?
  end

  test "non-moderator cannot approve" do
    other = users(:deactivated)
    other.update!(status: :active)
    sign_in_as other
    request = requests(:one_pending_for_garden)

    patch space_request_path(@closed, request, decision: "approve")
    assert_response :forbidden
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
