class Users::PasswordsController < ApplicationController
  def update
    user = Current.user

    unless user.authenticate(params[:current_password])
      redirect_to profile_path, alert: "Current password is incorrect."
      return
    end

    if user.update(params.permit(:password, :password_confirmation))
      redirect_to profile_path, notice: "Password updated."
    else
      redirect_to profile_path, alert: user.errors.full_messages.to_sentence
    end
  end
end
