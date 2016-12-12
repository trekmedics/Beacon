class MedicalDoctor < ActiveRecord::Base
  belongs_to :hospital

  validates :hospital, presence: { message: I18n.t('activerecord.errors.models.medical_doctor.attributes.hospital.presence') }
  validates :name, presence: { message: I18n.t('activerecord.errors.models.medical_doctor.attributes.name.presence') }
  validates :phone_number, format: { with: /\A\+\d{10,15}\z/, message: I18n.t('activerecord.errors.models.medical_doctor.attributes.phone_number.format') }

  def self.find_by_hospital(hospital)
    return MedicalDoctor.where(hospital: hospital)
  end

end
