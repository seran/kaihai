class Spaces::RequestsController < Spaces::BaseController
  before_action :require_moderator, only: :update

  def create
    if @space.visibility_private? && !@space.subscriber?(Current.user)
      request_record = @space.requests.find_or_create_by!(user: Current.user, status: :pending)
      notify_moderators(request_record)
      redirect_to space_path(@space), notice: "Request sent. Moderators will review it."
    else
      head :forbidden
    end
  end

  def update
    request_record = @space.requests.find(params[:id])
    fallback = space_management_path(@space)

    case params[:decision].to_s
    when "approve"
      request_record.approve!(by: Current.user)
      redirect_back fallback_location: fallback, notice: "Request approved."
    when "decline"
      request_record.decline!(by: Current.user)
      redirect_back fallback_location: fallback, notice: "Request declined."
    else
      redirect_back fallback_location: fallback, alert: "Unknown decision."
    end
  end

  private
    def notify_moderators(request_record)
      @space.moderators.find_each do |moderator|
        Notification.create!(
          recipient:  moderator,
          actor:      Current.user,
          notifiable: request_record,
          kind:       "space_request"
        )
      end
    end
end
