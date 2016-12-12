class DropIncidentMessageLogs < ActiveRecord::Migration
  def up
    drop_table :incident_message_logs
  end

  def down
    create_table :incident_message_logs do |t|
      t.references :incident, index: true
      t.string :from
      t.string :to
      t.string :message
      t.datetime :message_time_stamp
      t.timestamps null: false
    end
    add_foreign_key :incident_message_logs, :incidents
  end
end
