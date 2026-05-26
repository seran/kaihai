require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @one = users(:one)
    @two = users(:two)
  end

  test "valid with allowed kind" do
    n = Notification.new(recipient: @one, actor: @two, notifiable: @two, kind: "wave")
    assert_predicate n, :valid?
  end

  test "rejects unknown kinds" do
    n = Notification.new(recipient: @one, actor: @two, notifiable: @two, kind: "tickle")
    assert_not n.valid?
    assert_includes n.errors[:kind], "is not included in the list"
  end

  test "recipient and actor are optional" do
    n = Notification.new(notifiable: @one, kind: "wave")
    assert_predicate n, :valid?
  end

  test "unread? is true until marked read" do
    n = notifications(:unread_wave)
    assert_not n.read?
    n.mark_as_read!
    assert_predicate n, :read?
  end

  test "mark_as_read! is idempotent" do
    n = notifications(:read_comment)
    original_read_at = n.read_at
    n.mark_as_read!
    assert_in_delta original_read_at.to_i, n.reload.read_at.to_i, 1
  end

  test "unread scope returns only unread notifications" do
    assert_includes Notification.unread, notifications(:unread_wave)
    assert_not_includes Notification.unread, notifications(:read_comment)
  end

  test "for scope filters by recipient" do
    assert_equal Notification.where(recipient: @one).pluck(:id).sort,
                 Notification.for(@one).pluck(:id).sort
  end

  test "destroying recipient destroys their notifications" do
    assert_difference -> { Notification.count }, -2 do
      @one.destroy
    end
  end

  test "destroying actor nullifies actor on caused notifications" do
    @two.destroy
    notifications(:unread_wave).reload
    assert_nil notifications(:unread_wave).actor_id
  end
end
