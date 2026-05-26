class MagicLinksController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: :show
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_magic_link_path, alert: "Try again later." }

  def new
  end

  def create
    user = User.active.find_by(email_address: params[:email_address])
    SessionsMailer.magic_link(user).deliver_later if user

    redirect_to new_session_path, notice: "Sign-in link sent (if a user with that email address exists)."
  end

  def show
    if @user.active?
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      redirect_to new_magic_link_path, alert: "Your account is not active. Contact support for help."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_token_for!(:magic_link, params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      redirect_to new_magic_link_path, alert: "Sign-in link is invalid or has expired."
    end
end
