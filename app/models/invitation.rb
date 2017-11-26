# == Schema Information
#
# Table name: invitations
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  description    :text
#  competition_id :integer          not null
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emails         :string
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
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  # =================================
  # Associations
  # =================================
  belongs_to :competition
  belongs_to :user #proprietor#
  has_many :guests, :dependent => :delete_all
  has_many :users, :through => :guests 
  
  # =================================
  # Validations
  # =================================
  validates :name, presence: true

  # =================================
  # Instance Methods
  # =================================
  def set_guests(ids)
    ids.each {|i|
      unless i.empty? || users.exists?(i) 
        guests << Guest.new(:user_id => i, :invitation_id => id, :secret_hash => SecureRandom.hex(16))
      end  
    }
  end

  def create_user_by_emails
    if !emails.nil? && !emails.empty?
      emails.split(";").each {|e|
        if e =~ VALID_EMAIL_REGEX
          user = User.new
          user.email = e
          user.name = e.split("@").first
          user.role = "user"
          user.password = "000000"
          if user.save
            set_guests([user.id.to_s])
          end
        else
          errors.add(:emails, "E-mail inválido " << e)
        end  
      }
    end  
  end

end
