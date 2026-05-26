class Admin::Users::InvitationsController < Admin::BaseController
  def create
    email = params.dig(:user, :email_address).to_s.strip.downcase
    user  = User.find_or_initialize_by(email_address: email)

    if user.claimed?
      redirect_to admin_users_path, alert: "@#{user.handle} is already a member."
      return
    end

    user.assign_attributes(
      role:       :user,
      status:     :active,
      invited_by: Current.user,
      invited_at: Time.current
    )

    if user.save
      InvitationsMailer.invite(user).deliver_later
      redirect_to admin_users_path, notice: "Invitation sent to #{user.email_address}."
    else
      redirect_to admin_users_path, alert: form_error_message(user)
    end
  end
end
