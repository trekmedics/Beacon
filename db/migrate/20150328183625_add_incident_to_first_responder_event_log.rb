class AddIncidentToFirstResponderEventLog < ActiveRecord::Migration
  def change
    add_reference :first_responder_event_logs, :incident, index: true
    add_foreign_key :first_responder_event_logs, :incidents
  end
end
