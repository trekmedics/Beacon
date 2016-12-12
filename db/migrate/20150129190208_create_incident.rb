class CreateIncident < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.integer :state
      t.references :reporting_party, index: true
      t.references :incident_commander, index: true
      t.string :location
      t.integer :completion_status
      t.timestamps
    end
    add_foreign_key :incidents, :reporting_parties
    add_foreign_key :incidents, :incident_commanders
  end
end
