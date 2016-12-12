class Hospital < ActiveRecord::Base
  belongs_to :data_center
  has_many :medical_doctors, dependent: :destroy

  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  validates :data_center, presence: { message: I18n.t('activerecord.errors.models.hospital.attributes.data_center.presence') }
  validates :name, presence: { message: I18n.t('activerecord.errors.models.hospital.attributes.name.presence') }
  validates :name, uniqueness: { scope: :data_center_id,
    message: I18n.t('activerecord.errors.models.hospital.attributes.name.uniqueness') }
  def self.find_by_data_center(data_center)
    return Hospital.where(data_center_id: data_center.id).order(:name)
  end

  def to_s
    return self.name
  end
end
