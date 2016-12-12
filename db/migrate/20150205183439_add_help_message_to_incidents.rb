class AddHelpMessageToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :help_message, :string
  end
end
