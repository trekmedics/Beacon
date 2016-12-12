class DataCenterPolicy < ApplicationPolicy
  def set_user_data_center?
    return DataCenterPermission.authorized?(self.user, self.record)
  end
end
