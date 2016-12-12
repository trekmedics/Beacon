class RenameRequestForAssistancesToAssistanceRequests < ActiveRecord::Migration
  def self.up
    remove_index "request_for_assistances", ["first_responder_id"]
    remove_index "request_for_assistances", ["incident_id"]
    rename_table :request_for_assistances, :assistance_requests
    add_index "assistance_requests", ["first_responder_id"], name: "index_assistance_requests_on_first_responder_id"
    add_index "assistance_requests", ["incident_id"], name: "index_assistance_requests_on_incident_id"
  end

  def self.down
    remove_index "assistance_requests", ["first_responder_id"]
    remove_index "assistance_requests", ["incident_id"]
    rename_table :assistance_requests, :request_for_assistances
    add_index "request_for_assistances", ["first_responder_id"], name: "index_request_for_assistances_on_first_responder_id"
    add_index "request_for_assistances", ["incident_id"], name: "index_request_for_assistances_on_incident_id"
  end
end
