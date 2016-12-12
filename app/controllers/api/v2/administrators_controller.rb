module Api
  module V2
    class AdministratorsController < ApiController
      before_action :set_administrator, only: [:update, :destroy]

      def index
        @administrators = Administrator.find_by_data_center(@api_user.data_center).all
        render json: @administrators
      end

      def create
        @administrator = Administrator.new(administrator_params.merge(data_center: @api_user.data_center))
        if @administrator.save
          render json: @administrator
        else
          render json: ErrorsHelper.serialize(@administrator.errors), status: :unprocessable_entity
        end
      end

      def update
        if @administrator.update(administrator_params)
          render json: @administrator
        else
          render json: ErrorsHelper.serialize(@administrator.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @administrator.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@administrator.errors), status: :unprocessable_entity
        end
      end

    private

      def set_administrator
        @administrator = Administrator.find(params[:id])
      end

      def administrator_params
        return self.params.permit(:name, :phone_number, :email, :data_center_id)
      end
    end
  end
end
