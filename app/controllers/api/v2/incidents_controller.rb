module Api
  module V2
    class IncidentsController < ApiController
      before_action :set_incident, only: [:show, :message_log, :destroy]

      def index
        if params[:filter] == 'active'
          @incidents = Incident.fetch_active_incidents(@api_user.data_center).order(id: :desc)
        else
          @incidents = Incident.by_data_center(@api_user.data_center).all.order(id: :desc)
        end
      end

      def show
      end

      def message_log
      end

      def create
        @incident = IncidentManager.instance.handle_admin_created_incident(
          @api_user.data_center,
          params[:help_message],
          params[:location],
          params[:number_of_frs_to_allocate],
          params[:number_of_transport_vehicles_to_allocate],
          params[:subcategory_id]
        )
      end

      def edit_comment
        @incident = Incident.find(params[:incident_id])
        @incident.update_comment(params[:comment]) if @incident.present?
      end

      def cancel_incident
        @incident = Incident.find(params[:incident_id])
        @incident.cancel_incident!(:admin_cancel, params[:comment])
        render nothing: true, status: :accepted
      end

      def destroy
        @incident.cancel_incident!(:admin_cancel, params[:comment])
        render nothing: true, status: :accepted
      end

    private

      def set_incident
        @incident = Incident.find(params[:id])
      end
    end
  end
end
