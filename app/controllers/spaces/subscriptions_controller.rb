class Spaces::SubscriptionsController < Spaces::BaseController
  def create
    if @space.visibility_open?
      @space.subscriptions.find_or_create_by!(user: Current.user)
      redirect_to space_path(@space), notice: "Joined #{@space.name}."
    else
      head :forbidden
    end
  end

  def destroy
    @space.subscriptions.where(user: Current.user).destroy_all
    redirect_to space_path(@space), notice: "Left #{@space.name}."
  end
end
