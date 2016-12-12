module Api
  module V1
    class IncidentsController < AdministrativeInterfaceController
      before_action :set_incident, only: [:cancel_incident, :edit_comment]
      skip_before_action :verify_authenticity_token
      respond_to :json

      def index
        respond_with Incident.includes(:reporting_party).fetch_active_incidents(current_user.data_center).order(id: :desc)
      end

      def show
        respond_with Incident.by_data_center(current_user.data_center)
                             .includes(:reporting_party)
                             .includes(:message_log)
                             .find_by(id: params[:id])
      end

      def cancel_incident
        @incident.cancel_incident!(:admin_cancel, params[:comment])
        render nothing: true
      end

      def edit_comment
        @incident.update_comment(params[:comment])
        respond_with @incident
      end

    private

      def set_incident
        @incident = Incident.by_data_center(current_user.data_center).find_by_id(params[:incident_id])
      end
    end
  end
end
