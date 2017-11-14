# == Schema Information
#
# Table name: guests
#
#  id            :integer          not null, primary key
#  invitation_id :integer
#  user_id       :integer
#  secret_hash   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_guests_on_invitation_id  (invitation_id)
#  index_guests_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_249a5cb876  (invitation_id => invitations.id)
#  fk_rails_9b121eeada  (user_id => users.id)
#

class Guest < ApplicationRecord
  belongs_to :invitation
  belongs_to :user
end
