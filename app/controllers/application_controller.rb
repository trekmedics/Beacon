class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_data_center
  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError do |exception|
    redirect_to root_url, notice: I18n.t('system.not_authorized')
  end

private

  def configure_data_center
    raise StandardError.new('"Set Data Center" needs to be implemented in a subclass.')
  end

  def set_locale
  	if current_user.present?
  		if current_user.locale.present?
  			I18n.locale = current_user.locale
  		else
	    	I18n.locale = ApplicationConfiguration.instance.admin_language
			end
    end
  end

  def json_request?
    return self.request.format.json?
  end

  def authenticate_from_token!
    @api_user = User.authenticate_from_token!(params[:sid], params[:auth_token])
    render json: { error: 'Authentication failed.' }, status: :unauthorized if @api_user.blank?
  end
end
