# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  provider               :string
#  uid                    :string
#  name                   :string
#  handle                 :string
#  bio                    :text
#  location               :string
#  company                :string
#  role                   :integer          default("user")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  remote_avatar_url      :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord

  # =================================
  # Constants
  # =================================

  DEFAULT_PASSWORD_SIZE = 64
  enum role: { user: 0, admin: 1, general_admin: 2, competition_admin: 3 }

  # =================================
  # Plugins
  # =================================
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [ :facebook, :linkedin, :google_oauth2 ]
  has_attached_file :avatar,
  {
    path: "users/avatars/:hash.:extension",
    url: "users/avatars/:hash.:extension",
    styles: { big: '128x128#', med: '64x64#', min: '32x32#' },
    hash_secret: Datoca.config.dig('attachments', 'users', 'avatar', 'secret'),
    hash_digest: Datoca.config.dig('attachments', 'users', 'avatar', 'digest'),
    default_url: 'fallback-user.svg' 
  }
  attr_reader :avatar_remote_url
  # =================================
  # Associations
  # =================================

  has_many :acceptances
  has_many :rankings, as: :competitor
  has_many :submissions, as: :competitor
  has_many :individual_competitions, -> { order(:created_at).distinct }, through: :submissions, source: :competition
  has_many :team_competitions, through: :teams, source: :competitions
  has_many :guests
  has_and_belongs_to_many :teams

  # =================================
  # Validations
  # =================================

  validates :bio, length: { maximum: 256 }, allow_blank: true
  validates :name, presence: true
  validates :avatar, {
    attachment_content_type: { content_type: ['image/jpeg', 'image/gif', 'image/png', '/\Aimage\/.*\Z/'] },
    attachment_file_name: { matches: [/gif\z/, /png\z/, /jpe?g\z/, /.*\z/] }
  }

  # =================================
  # Class Methods
  # =================================

  def self.from_omniauth(auth) 
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token(DEFAULT_PASSWORD_SIZE)
      user.name = auth.info.name
      user.avatar = auth.info.image
    end
  end

  def self.create_user_from_invitation_by_email(email)
    User.create(email: email, name: email.split("@").first, role: 'user', password: SecureRandom.hex(8))
  end
  
  # =================================
  # Instance Methods
  # =================================

  def update_without_password(params, *options)
    params.delete(:current_password)
    super(params)
  end

  def is_admin
    admin? || general_admin? 
  end

  def roles_by_permission(current_user)
    if current_user.admin?
      User.roles.keys.to_a
    elsif current_user.general_admin?
      User.roles.select{ |r| r == role || r == 'user' || r == 'competition_admin'}.keys.to_a
    end  
  end

end
