require "test_helper"

class FeedControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(User.take) }

  test "index" do
    get root_path
    assert_response :success
  end
end
