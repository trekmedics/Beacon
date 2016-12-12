class CreateMessageLogs < ActiveRecord::Migration
  def change
    create_table :message_logs do |t|
      t.references :incident, index: true
      t.string :resource_type
      t.integer :resource_id
      t.string :resource_name
      t.string :resource_phone_number
      t.boolean :is_incoming
      t.string :message
      t.timestamps null: false
    end
    add_foreign_key :message_logs, :incidents
  end
end
