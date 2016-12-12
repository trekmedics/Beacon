class DataCenterPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :data_center

  validates :user, presence: true
  validates :data_center, presence: true

  def self.authorized?(user, data_center)
    return true if user.user_role.name == 'Admin'
    return DataCenterPermission.find_by(user: user, data_center: data_center).present?
  end

  def self.authorized_data_centers(user)
    return DataCenter.all if user.user_role.name == 'Admin'
    return DataCenter.joins(:data_center_permissions)
                     .where(data_center_permissions: { user: user })
  end

  def self.set_permissions(user_id, data_center_ids)
    user = User.find_by(id: user_id)
    data_center_ids.each do |data_center_id|
      DataCenterPermission.find_or_create_by(user: user, data_center_id: data_center_id)
    end
    DataCenterPermission.where(user: user).each do |data_center_permission|
      should_destroy = true
      data_center_ids.each do |data_center_id|
        should_destroy = false if data_center_id == data_center_permission.data_center_id
      end
      data_center_permission.destroy if should_destroy
    end
  end
end
