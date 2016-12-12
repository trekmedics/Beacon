class AddIsAcceptingFirstRespondersToIncident < ActiveRecord::Migration
  def change
    add_column :incidents, :is_accepting_first_responders, :boolean, null: false, default: false
  end
end
