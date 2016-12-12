module Api
  module V2
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?
      skip_before_action :authenticate_user!
      prepend_before_action :authenticate_from_token!
      respond_to :json

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ArgumentError, with: :argument_error

    private

      def configure_data_center
        ApplicationConfiguration.instance.data_center = @api_user.data_center if @api_user.present?
      end

      def record_not_found
        render json: { error: 'Record Not Found' }, status: :not_found
      end

      def user_not_authorized(exception)
        render json: { error: 'User Not Authorized' }, status: :forbidden
      end

      def argument_error(exception)
        render json: { error: "Argument Error: #{exception.message}" }, status: :unprocessable_entity
      end
    end
  end
end
