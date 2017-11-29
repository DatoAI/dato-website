require 'test_helper'

class InvitationTest < ActiveSupport::TestCase

  test 'It should create an invitation' do
    invitation = create(:invitation)
    assert invitation.save
  end

  test 'It should create an invitation with guests' do
    invitation = create(:invitation)
    invitation.guests << create(:guest)
    assert invitation.save
  end

  test 'It should create an invitation with guests by emails' do
    invitation = create(:invitation)
    invitation.guests << create(:guest)
    invitation.emails = Laranja::Internet.email(Laranja::Nome.nome)
    invitation.emails << ';' << Laranja::Internet.email(Laranja::Nome.nome)
    assert invitation.save
  end

end
