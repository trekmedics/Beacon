module Api
  module V2
    class SettingsController < ApiController
      before_action :set_setting, only: [:update]

      def index
        @settings = Setting.by_data_center(@api_user.data_center).all.order(id: :desc)
        render json: @settings
      end

      def update
        if @setting.update(setting_params)
          render json: @setting
        else
          render json: ErrorsHelper.serialize(@setting.errors), status: :unprocessable_entity
        end
      end

    private

      def set_setting
        @setting = Setting.find(params[:id])
      end

      def setting_params
        return self.params.permit(:value)
      end
    end
  end
end
