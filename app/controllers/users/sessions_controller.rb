class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  def configure_data_center
    ApplicationConfiguration.instance.data_center = current_user.data_center if current_user.present?
  end

protected

  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :password, :remember_me) }
  end

  def after_sign_out_path_for(resource)
    return new_user_session_path
  end
end
