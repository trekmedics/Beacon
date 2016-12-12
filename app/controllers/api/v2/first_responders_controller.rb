module Api
  module V2
    class FirstRespondersController < ApiController
      before_action :set_first_responder, only: [:update, :destroy, :performance_report]

      def index
        @first_responders = FirstResponder.by_data_center(@api_user.data_center).all.order(id: :desc)
        render json: @first_responders
      end

      def create
        @first_responder = FirstResponder.new(first_responder_params.merge(data_center: @api_user.data_center))
        if @first_responder.save
          render json: @first_responder
        else
          render json: ErrorsHelper.serialize(@first_responder.errors), status: :unprocessable_entity
        end
      end

      def update
        if @first_responder.update(first_responder_params)
          render json: @first_responder
        else
          render json: ErrorsHelper.serialize(@first_responder.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @first_responder.soft_delete
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@first_responder.errors), status: :unprocessable_entity
        end
      end

      def performance_report
        @first_responder_report = FirstResponderReport.new(@first_responder)
        render json: @first_responder_report
      end

      def log_in
        @first_responder = FirstResponder.find(params[:first_responder_id])
        @first_responder.admin_log_in! if @first_responder.present?
        render json: @first_responder
      end

      def log_out
        @first_responder = FirstResponder.find(params[:first_responder_id])
        @first_responder.log_out! if @first_responder.present?
        render json: @first_responder
      end

    private

      def set_first_responder
        @first_responder = FirstResponder.find(params[:id])
      end

      def first_responder_params
        processed_params = self.params.permit(:name, :phone_number, :locale, :transportation_mode)
        processed_params[:transportation_mode] = processed_params[:transportation_mode].to_i if processed_params[:transportation_mode].present?
        return processed_params
      end
    end
  end
end
