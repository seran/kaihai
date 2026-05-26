class Notifications::ReadStatusesController < ApplicationController
  def update
    Current.user.notifications.unread.update_all(read_at: Time.current)
    Notification.broadcast_sidebar_for(Current.user)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
