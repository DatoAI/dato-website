# == Schema Information
#
# Table name: competitions
#
#  id                        :integer          not null, primary key
#  name                      :string
#  max_team_size             :integer
#  metric                    :integer
#  total_prize               :decimal(9, 2)
#  deadline                  :datetime
#  expected_csv_id_column    :string           default("id")
#  expected_csv_val_column   :string           default("value")
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  daily_attempts            :integer          default(3)
#  expected_csv_line_count   :integer          default(0)
#  metric_sort               :string           default("asc")
#  expected_csv_file_name    :string
#  expected_csv_content_type :string
#  expected_csv_file_size    :integer
#  expected_csv_updated_at   :datetime
#  ilustration_file_name     :string
#  ilustration_content_type  :string
#  ilustration_file_size     :integer
#  ilustration_updated_at    :datetime
#  visible                   :integer          default("enabled")
#  type_competition          :integer          default("open")
#

class Competition < ApplicationRecord

  # =================================
  # Constants
  # =================================

  REQUIRED_INSTRUCTIONS = ['Avaliação', 'Dados', 'Descrição', 'Regras']

  enum metric: Metrorb.metrics_abbr_and_id
  enum visible: { enabled: 0, disabled: 1 }
  enum type_competition: { open: 0, specific: 1 }

  # =================================
  # Plugins
  # =================================

  has_attached_file :expected_csv,
  {
    path: "competitions/:hash.:extension",
    url: "competitions/:hash.:extension",
    hash_secret: Datoca.config.dig('attachments', 'competitions', 'expected_csv', 'secret'),
    hash_digest: Datoca.config.dig('attachments', 'competitions', 'expected_csv', 'digest')
  }
  has_attached_file :ilustration,
  {
    path: "competitions/:hash.:extension",
    url: "competitions/:hash.:extension",
    styles: { med: '64x64#' },
    hash_secret: Datoca.config.dig('attachments', 'competitions', 'ilustration', 'secret'),
    hash_digest: Datoca.config.dig('attachments', 'competitions', 'ilustration', 'digest'),
    default_url: 'fallback-competition.svg'
  }

  # =================================
  # Associations
  # =================================

  has_many :rankings
  has_many :submissions
  has_many :acceptances
  has_many :users, -> { order(:created_at).distinct }, through: :submissions, source: :competitor, source_type: 'User'
  has_many :teams, -> { order(:created_at).distinct }, through: :submissions, source: :competitor, source_type: 'Team'
  has_many :invitations
  has_many :guests, :through => :invitations
  has_many :instructions, inverse_of: :competition, dependent: :destroy
  has_one :description,     -> { where name: 'Descrição' }, class_name: 'Instruction', inverse_of: :competition
  has_one :evaluation_text, -> { where name: 'Avaliação' }, class_name: 'Instruction', inverse_of: :competition
  
  accepts_nested_attributes_for :instructions
  accepts_nested_attributes_for :description
  accepts_nested_attributes_for :evaluation_text

  # =================================
  # Validations
  # =================================

  validates :name, presence: true
  validates :metric, presence: true
  validate :has_required_instructions
  validates :expected_csv, {
    presence: true,
    attachment_content_type: { content_type: Attachment::CSV_CONTENT_TYPES },
    attachment_file_name: { matches: /csv\z/ }
  }
  validates :ilustration, {
    attachment_content_type: { content_type: ['image/jpeg', 'image/gif', 'image/png'] },
    attachment_file_name: { matches: [/gif\z/, /png\z/, /jpe?g\z/] }
  }

  # =================================
  # Callbacks
  # =================================

  after_expected_csv_post_process :count_lines
  before_save :set_metric_sort, if: :metric_changed?

  # =================================
  # Class Methods
  # =================================

  def self.new_with_instructions
    self.new.tap do |c|
      c.instructions.build(REQUIRED_INSTRUCTIONS.map { |name| { name: name} })
    end
  end

  def self.competition_name_and_key_specific
    Competition.where(type_competition: :specific).map { |competition| [competition.name, competition.id] }
  end

  # =================================
  # Instance Methods
  # =================================

  def has_required_instructions
    unless (REQUIRED_INSTRUCTIONS & instructions.map(&:name)).size == REQUIRED_INSTRUCTIONS.size
      errors.add(:instructions, "precisa conter pelo menos as seguintes instruções: " + REQUIRED_INSTRUCTIONS.join(', '))
    end
  end

  def files_can_be_downloaded_by?(user)
    acceptances.where(user: user).any?
  end

  def metric_name
    Metrorb.metrics_hash[metric.to_sym].name
  end

  def disable_visible
    self.disabled!
  end
  
  def enable_visible
    self.enabled!
  end

  private

  def count_lines
    begin
      self.expected_csv_line_count = CSV.new(Paperclip.io_adapters.for(expected_csv).read).read.size
    rescue CSV::MalformedCSVError => e
      errors.add(:expected_csv, "Arquivo 'Expected csv' está mal formatado")
    end
  end

  def set_metric_sort
    self.metric_sort = Metrorb.metrics_hash[metric.to_sym].sort_direction.to_s
  end

end
