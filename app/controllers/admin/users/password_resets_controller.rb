class Admin::Users::PasswordResetsController < Admin::BaseController
  def create
    user = User.find(params[:user_id])
    PasswordsMailer.reset(user).deliver_later
    redirect_to admin_user_path(user), notice: "Password reset link sent to #{user.email_address}."
  end
end
