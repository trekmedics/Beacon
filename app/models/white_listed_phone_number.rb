class WhiteListedPhoneNumber < ActiveRecord::Base
  belongs_to :data_center

  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  validates :data_center, presence: { message: I18n.t('activerecord.errors.models.white_listed_phone_number.attributes.data_center.presence') }
  validates :phone_number, format: { with: /\A\+\d{10,15}\z/, message: I18n.t('activerecord.errors.models.white_listed_phone_number.attributes.phone_number.format') }
  validates :phone_number, uniqueness: { message: I18n.t('activerecord.errors.models.white_listed_phone_number.attributes.phone_number.uniqueness') }
  validate :phone_number_not_used_by_first_responder

  def self.check_white_list(data_center, phone_number)
    if ApplicationConfiguration.instance.white_list_enabled?
      return WhiteListedPhoneNumber.where(data_center: data_center, phone_number: phone_number).present?
    end
    return true
  end

  def self.find_by_phone_number(phone_number)
    return WhiteListedPhoneNumber.find_by(phone_number: phone_number)
  end

private

  def phone_number_not_used_by_first_responder
    if FirstResponder.where(phone_number: self.phone_number).where.not(state: FirstResponder.states[:disabled]).present?
      self.errors.add(:phone_number, I18n.t('activerecord.errors.models.white_listed_phone_number.attributes.phone_number.phone_number_used_by_first_responder'))
    end
  end
end
