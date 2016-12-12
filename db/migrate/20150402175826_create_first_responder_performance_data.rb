class CreateFirstResponderPerformanceData < ActiveRecord::Migration
  def change
    create_table :first_responder_performance_data do |t|
      t.references :first_responder, null: false, index: true, foreign_key: true
      t.references :incident, null: false, index: true, foreign_key: true
      t.timestamp :time_of_original_request
      t.boolean :did_reply_original_request
      t.timestamp :time_of_original_request_reply
      t.timestamp :time_of_additional_request
      t.boolean :did_reply_additional_request
      t.timestamp :time_of_additional_request_reply
      t.integer :eta
      t.boolean :was_assigned
      t.boolean :did_confirm_on_scene
      t.timestamp :time_of_confirm_on_scene
      t.boolean :did_cancel
      t.boolean :was_unable_to_locate
      t.boolean :was_incident_commander
      t.boolean :did_request_resources
      t.integer :vehicles_requested
      t.boolean :did_confirm_transport
      t.timestamp :time_of_confirm_transport
      t.integer :patients_transported
      t.integer :hospital_eta
      t.references :hospital, index: true, foreign_key: true
      t.boolean :did_confirm_arrival
      t.timestamp :time_of_confirm_arrival
      t.boolean :did_complete
      t.timestamp :time_of_incident_complete
      t.timestamps null: false
    end
  end
end
