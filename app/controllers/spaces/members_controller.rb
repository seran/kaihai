class Spaces::MembersController < Spaces::BaseController
  before_action :require_moderator

  def update
    subscription = @space.subscriptions.find(params[:id])
    new_role     = params.dig(:subscription, :role).to_s

    unless Subscription.roles.key?(new_role)
      redirect_to space_management_path(@space), alert: "Unknown role."
      return
    end

    if subscription.moderator? && new_role == "member" && @space.moderators.count == 1
      redirect_to space_management_path(@space), alert: "A space needs at least one moderator."
      return
    end

    if subscription.update(role: new_role)
      redirect_to space_management_path(@space), notice: role_change_notice(subscription, new_role)
    else
      redirect_to space_management_path(@space), alert: "Couldn't update role."
    end
  end

  def destroy
    subscription = @space.subscriptions.find(params[:id])
    subscription.destroy
    redirect_to space_management_path(@space), notice: "Member removed."
  end

  private
    def role_change_notice(subscription, new_role)
      handle = "@#{subscription.user.handle}"
      new_role == "moderator" ? "Promoted #{handle} to moderator." : "Demoted #{handle} to member."
    end
end
