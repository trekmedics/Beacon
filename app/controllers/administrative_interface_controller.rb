class AdministrativeInterfaceController < ApplicationController

  def index
  end

private

  def configure_data_center
    ApplicationConfiguration.instance.data_center = current_user.data_center
  end

  def authorize_admin_user
    if current_user.user_role.name != 'Admin'
      redirect_to root_url, notice: I18n.t('system.not_authorized')
    end
  end
end
