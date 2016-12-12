module Api
  module V1
    class FirstRespondersController < AdministrativeInterfaceController
      before_action :set_first_responder, only: [:log_in, :log_out, :message]
      skip_before_action :verify_authenticity_token
      respond_to :json

      def index
        first_responders = FirstResponder.by_data_center(current_user.data_center)
        if params[:incident_id].present?
          first_responders = first_responders.joins(:assistance_requests)
                                             .where(assistance_requests: { incident_id: params[:incident_id] })
                                             .order('assistance_requests.id ASC')
        else
          first_responders = first_responders.where.not(state: 0).order(:name)
        end
        respond_with first_responders
      end

      def log_in
        @first_responder.admin_log_in! if @first_responder.present?
        respond_with @first_responder
      end

      def log_out
        @first_responder.log_out! if @first_responder.present?
        respond_with @first_responder
      end

      def message
        success, message = OutgoingMessageService.send_ad_hoc_text_message(@first_responder, params[:message])
        render json: { success: success, message: message }
      end

    private

      def set_first_responder
        @first_responder = FirstResponder.by_data_center(current_user.data_center).find_by_id(params[:first_responder_id])
      end
    end
  end
end

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
