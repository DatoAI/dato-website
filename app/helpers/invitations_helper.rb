module InvitationsHelper

  def instructions_error(invitation)
    return if invitation.errors&.messages&.dig(:instructions).blank?
    content_tag(:div, class: 'notification is-danger') do
      content_tag(:button, class: 'delete') do
      end + invitation.errors.messages[:instructions].join
    end
  end

end
