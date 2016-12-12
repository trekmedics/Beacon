class CreateIncidentEventLogs < ActiveRecord::Migration
  def change
    create_table :incident_event_logs do |t|
      t.references :incident, index: true
      t.integer :from_state
      t.integer :to_state
      t.datetime :event_time_stamp

      t.timestamps null: false
    end
    add_foreign_key :incident_event_logs, :incidents
  end
end
