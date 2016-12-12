class Administrator < ActiveRecord::Base
  belongs_to :data_center
  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  validates :phone_number, format: { with: /\A\+\d{10,15}\z/,
    message: I18n.t('activerecord.errors.models.administrator.attributes.phone_number.format') }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/,
    message: I18n.t('activerecord.errors.models.administrator.attributes.email.format') }
  validates :phone_number, uniqueness: { scope: :data_center_id,
    message: I18n.t('activerecord.errors.models.administrator.attributes.phone_number.uniqueness') }

  def self.find_by_data_center(data_center)
    return Administrator.where(data_center_id: data_center.id).order(:name)
  end

end
