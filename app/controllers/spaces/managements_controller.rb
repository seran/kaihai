class Spaces::ManagementsController < Spaces::BaseController
  before_action :require_moderator

  def show
    @subscriptions = @space.subscriptions.includes(:user).order("users.name")
    @pending_requests = @space.requests.pending.includes(:user).order(created_at: :desc)
  end

  def update
    if @space.update(space_params)
      redirect_to space_management_path(@space), notice: "Space updated."
    else
      @subscriptions = @space.subscriptions.includes(:user).order("users.name")
      @pending_requests = @space.requests.pending.includes(:user).order(created_at: :desc)
      flash.now[:alert] = form_error_message(@space)
      render :show, status: :unprocessable_entity
    end
  end

  private
    def space_params
      params.expect(space: %i[ name handle description visibility ])
    end
end
