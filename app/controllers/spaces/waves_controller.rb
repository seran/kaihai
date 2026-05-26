class Spaces::WavesController < Spaces::BaseController
  def create
    to_user = User.find(params[:to_user_id])
    Wave.find_or_create_by!(from_user: Current.user, to_user: to_user, space: @space)

    Current.user.notifications.unread
                .where(actor: to_user, kind: "wave")
                .update_all(read_at: Time.current)

    redirect_back fallback_location: space_path(@space)
  end
end
