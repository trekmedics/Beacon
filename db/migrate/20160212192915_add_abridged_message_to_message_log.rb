class AddAbridgedMessageToMessageLog < ActiveRecord::Migration
  def change
    add_column :message_logs, :abridged_message, :string
  end
end
