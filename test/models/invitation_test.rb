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

  test 'It not should create an user by emails invalid' do
    invitation = create(:invitation)
    invitation.emails = 'invalid_email@invalid_email'
    invitation.create_user_by_emails
    assert_equal true, invitation.users.empty? 
  end

  test 'It should create an user by emails' do
    invitation = create(:invitation)
    invitation.emails = 'batman@gmail.com'
    invitation.create_user_by_emails
    assert_equal true, User.exists?(email: 'batman@gmail.com')
    assert_equal User.find_by(email: 'batman@gmail.com'), invitation.users.first
  end

  test 'It should must add guests who are already registered' do
    invitation = create(:invitation)
    user = create(:user)
    invitation.set_guests([user.id.to_s])
    assert_equal false, invitation.users.empty? 
    assert_equal user, invitation.users.first
  end

  test 'It not should not invite the same user more than once' do
    invitation = create(:invitation)
    invitation.guests << create(:guest)
    invitation.set_guests([invitation.users.first.id.to_s])
    assert_equal 1, invitation.users.length
  end

end
