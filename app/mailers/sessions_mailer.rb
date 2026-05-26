class SessionsMailer < ApplicationMailer
  def magic_link(user)
    @user = user
    @token = user.generate_token_for(:magic_link)
    mail subject: "Your sign-in link", to: user.email_address
  end
end
