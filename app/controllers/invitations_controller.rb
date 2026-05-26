class InvitationsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :ensure_setup_complete
  before_action :set_user_by_token

  def edit
  end

  def update
    if @user.update(invitation_params.merge(invited_at: nil))
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome to #{Current.account&.name.presence || 'Kaihai'}."
    else
      flash.now[:alert] = form_error_message(@user)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_token_for!(:invitation, params[:token])

      unless @user.pending_invitation?
        redirect_to new_session_path, alert: "This invitation is no longer valid."
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      redirect_to new_session_path, alert: "Invitation link is invalid or has expired."
    end

    def invitation_params
      params.expect(user: %i[ name handle password password_confirmation ])
    end
end
