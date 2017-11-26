class InvitationMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers 
  default from: Datoca.config.dig('devise', 'mailer', 'sender')

  def welcome_email(guest)                                                                                                                                
    @user = guest.user
    @url = root_url
    @url_new_password = new_user_password_url
    @competicao = guest.invitation.competition
    mail(to: @user.email, subject: "Convite de competição da Dato!")
  end
end

