class CreateFirstResponderIncidents < ActiveRecord::Migration
  def change
    create_table :first_responder_incidents do |t|
      t.references :first_responder, index: true
      t.references :incident, index: true

      t.timestamps
    end
    add_foreign_key :first_responder_incidents, :first_responders
    add_foreign_key :first_responder_incidents, :incidents
  end
end
