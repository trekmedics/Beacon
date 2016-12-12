class AddCurrentToFirstResponderIncidents < ActiveRecord::Migration
  def change
    add_column :first_responder_incidents, :is_current, :boolean, null: false, default: true
  end
end
