class RemoveLocationStatusFromFirstResponder < ActiveRecord::Migration
  def self.up
    remove_column :first_responders, :location_status, null: false, default: 0
  end
  def self.down
    add_column :first_responders, :location_status, null: false, default: 0
  end
end
