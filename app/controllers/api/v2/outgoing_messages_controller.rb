module Api
  module V2
    class OutgoingMessagesController < ApiController
      def create
        first_responder = FirstResponder.find(params[:first_responder_id])
        success, message = OutgoingMessageService.send_ad_hoc_text_message(first_responder, params[:message])
        if success
          render json: { message: message }
        else
          render json: { error: message }, status: :unprocessable_entity
        end
      end
    end
  end
end
