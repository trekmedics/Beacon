class ChangeStateTypeInLogs < ActiveRecord::Migration
  def self.up
    change_column :first_responder_event_logs,  :from_state,  :string
    change_column :incident_event_logs,         :from_state,  :string
    change_column :first_responder_event_logs,  :to_state,    :string
    change_column :incident_event_logs,         :to_state,    :string
  end
  def self.down
    change_column :first_responder_event_logs,  :from_state,  :integer
    change_column :incident_event_logs,         :from_state,  :integer
    change_column :first_responder_event_logs,  :to_state,    :integer
    change_column :incident_event_logs,         :to_state,    :integer
  end
end
