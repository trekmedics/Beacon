module Api
  module V1
    class IncomingMessagesController < AdministrativeInterfaceController
      skip_before_action :verify_authenticity_token

      def create
        IncomingMessageService.process_message(params['From'], params['Body'])
        render nothing: true
      end

      def admin_reporting_party
        incident = Incident.find_by(id: params['incident_id'])
        IncidentManager.instance.handle_admin_reporting_party_message(incident, params['message'])
        render nothing: true
      end
    end
  end
end
