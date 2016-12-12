class ChangeEtaToTime < ActiveRecord::Migration
  def self.up
    remove_column :first_responder_incidents,  :eta, :integer
    add_column :first_responder_incidents,  :eta, :datetime
  end
  def self.down
    remove_column :first_responder_incidents,  :eta, :datetime
    add_column :first_responder_incidents,  :eta, :integer
  end
end
