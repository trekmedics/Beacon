class AddEtaToFirstResponderIncidents < ActiveRecord::Migration
  def change
    add_column :first_responder_incidents, :eta, :integer
  end
end
