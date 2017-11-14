# == Schema Information
#
# Table name: invitations
#
#  id             :integer          not null, primary key
#  name           :string
#  description    :text
#  competition_id :integer
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_invitations_on_competition_id  (competition_id)
#  index_invitations_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_7eae413fe6  (user_id => users.id)
#  fk_rails_fffe3e04b6  (competition_id => competitions.id)
#

class Invitation < ApplicationRecord
  belongs_to :competition
  belongs_to :user #proprietor#
  

end
