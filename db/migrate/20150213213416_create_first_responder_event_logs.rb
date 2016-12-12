class CreateFirstResponderEventLogs < ActiveRecord::Migration
  def change
    create_table :first_responder_event_logs do |t|
      t.references :first_responder, index: true
      t.integer :from_state
      t.integer :to_state
      t.datetime :event_time_stamp

      t.timestamps null: false
    end
    add_foreign_key :first_responder_event_logs, :first_responders
  end
end
