require "test_helper"

class SpacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @one    = users(:one)
    @two    = users(:two)
    @open   = spaces(:open_lounge)
    @closed = spaces(:private_garden)
    sign_in_as @two
  end

  test "index renders the discover page" do
    get spaces_path
    assert_response :success
    assert_select "h1", "Spaces"
    assert_select "h3", text: @open.name
    assert_select "h3", text: @closed.name
  end

  test "show renders the space" do
    get space_path(@open)
    assert_response :success
    assert_select "h1", @open.name
  end

  test "create makes the creator a moderator" do
    assert_difference -> { Space.count }, +1 do
      post spaces_path, params: { space: { name: "New Room", handle: "new_room", visibility: "open" } }
    end
    space = Space.find_by(handle: "new_room")
    assert_redirected_to space_path(space)
    assert space.moderator?(@two)
  end

  private
    def sign_in_as(user)
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
end
