class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications
                            .includes(:actor, :notifiable)
                            .order(created_at: :desc)
  end
end
