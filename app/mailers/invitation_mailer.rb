class InvitationMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers 
  default from: Datoca.config.dig('devise', 'mailer', 'sender')

  def welcome_email(guest)                                                                                                                                
    @user = guest.user
    @url = root_url
    @competicao = guest.invitation.competition
    mail(to: @user.email, subject: "Convite de competição da Dato!")
  end
end

