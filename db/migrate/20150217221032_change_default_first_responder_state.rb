class ChangeDefaultFirstResponderState < ActiveRecord::Migration
  def self.up
    change_column :first_responders,  :state, :integer, :default => 1, :null => false
    remove_column :first_responders,  :is_deleted
  end
  def self.down
    change_column :first_responders,  :state, :integer, :default => 0, :null => false
    add_column    :first_responders,  :is_deleted, :boolean, :default => f, :null => false
  end
end
