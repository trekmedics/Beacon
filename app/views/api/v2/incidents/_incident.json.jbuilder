json.extract! incident, :id, :state, :help_message, :location, :number_of_frs_to_allocate, :number_of_transport_vehicles_to_allocate, :comment, :created_at, :updated_at
json.state_string incident.state_string
json.subcategory_string incident.subcategory_string
json.reporting_party(incident.reporting_party, :id, :phone_number, :is_admin) if incident.reporting_party.present?
json.incident_commander(incident.incident_commander, :id, :name, :phone_number) if incident.incident_commander.present?
