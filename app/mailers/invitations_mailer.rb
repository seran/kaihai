class InvitationsMailer < ApplicationMailer
  def invite(user)
    @user    = user
    @inviter = user.invited_by
    mail subject: "You're invited to #{Current.account&.name.presence || 'Kaihai'}",
         to: user.email_address
  end
end
