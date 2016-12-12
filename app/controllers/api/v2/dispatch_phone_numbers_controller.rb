module Api
  module V2
    class DispatchPhoneNumbersController < ApiController
      before_action :set_dispatch_phone_number, only: [:update, :destroy]

      def index
        @dispatch_phone_numbers = WhiteListedPhoneNumber.by_data_center(@api_user.data_center).order(id: :desc)
        render json: @dispatch_phone_numbers
      end

      def create
        data_center_id = params[:data_center_id] || @api_user.data_center.id
        @dispatch_phone_number = WhiteListedPhoneNumber.new(dispatch_phone_number_params.merge(data_center_id: data_center_id))
        if @dispatch_phone_number.save
          render json: @dispatch_phone_number
        else
          render json: ErrorsHelper.serialize(@dispatch_phone_number.errors), status: :unprocessable_entity
        end
      end

      def update
        if @dispatch_phone_number.update(dispatch_phone_number_params)
          render json: @dispatch_phone_number
        else
          render json: ErrorsHelper.serialize(@dispatch_phone_number.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @dispatch_phone_number.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@dispatch_phone_number.errors), status: :unprocessable_entity
        end
      end

    private

      def set_dispatch_phone_number
        @dispatch_phone_number = WhiteListedPhoneNumber.find(params[:id])
      end

      def dispatch_phone_number_params
        return self.params.permit(:data_center_id, :phone_number, :name)
      end
    end
  end
end
