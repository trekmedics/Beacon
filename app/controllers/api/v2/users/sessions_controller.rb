class Api::V2::Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, if: :json_request?
  skip_before_action :verify_signed_out_user
  skip_before_action :set_locale, only: [:create]
  prepend_before_action :authenticate_from_token!, only: [:destroy]
  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
    self.sign_in(self.resource)
    if self.resource.api_sign_in
      render json: self.resource
    else
      render json: { error: 'There was an error signing in.' }, status: :unprocessable_entity
    end
  end

  def destroy
    if @api_user.api_sign_out
      render json: { success: 'User signed out.' }
    else
      render json: { error: 'There was an error siging out.' }, status: :unprocessable_entity
    end
  end

private

  def configure_data_center
    ApplicationConfiguration.instance.data_center = @api_user.data_center if @api_user.present?
  end
end
