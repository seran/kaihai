class SetupsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :ensure_setup_complete

  before_action :ensure_setup_pending

  def new
    @user    = User.new
    @account = Current.account
  end

  def create
    @user    = User.new(user_params.merge(role: :admin))
    @account = Current.account

    User.transaction do
      @user.save!
      @account.update!(account_params)
      start_new_session_for(@user)
    end

    redirect_to root_path, notice: "Welcome to #{@account.name}."
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = form_error_message(@user.errors.any? ? @user : @account)
    render :new, status: :unprocessable_entity
  end

  private
    def user_params
      params.require(:user).permit(:name, :handle, :email_address, :password, :password_confirmation)
    end

    def account_params
      params.require(:account).permit(:name, :tagline)
    end

    def ensure_setup_pending
      redirect_to root_path if Current.account.configured?
    end
end
