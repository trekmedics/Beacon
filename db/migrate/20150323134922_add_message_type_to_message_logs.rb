class AddMessageTypeToMessageLogs < ActiveRecord::Migration
  def change
    add_column :message_logs, :message_type, :integer, default: 0
  end
end
