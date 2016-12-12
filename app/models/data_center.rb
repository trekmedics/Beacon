class DataCenter < ActiveRecord::Base
  has_many :users
  has_many :hospitals, dependent: :destroy
  has_many :white_listed_phone_numbers, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :data_center_permissions, dependent: :destroy

  after_create :generate_settings

  def self.find_by_beacon_number(phone_number)
    settings = Setting.where(key: 'beacon_number', value: phone_number)
    if settings.size == 1
      return settings.first.data_center
    else
      raise StandardError.new("Data Center: not able to determine data center by beacon number. Number of data centers = #{settings.size}.")
    end
    return nil
  end

  def self.authorized(user)
    return DataCenterPermission.authorized_data_centers(user)
  end

  def authorized?(user)
    return DataCenterPermission.authorized?(user, self)
  end

  def to_s
    return self.name
  end

private

  def generate_settings
    ApplicationConfiguration.generate_new_settings(self)
  end
end
