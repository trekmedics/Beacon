class CreateFirstResponders < ActiveRecord::Migration
  def change
    create_table :first_responders do |t|
      t.integer :state, null: false, default: 0
      t.integer :transportation_mode, null: false, default: 0
      t.integer :location_status, null: false, default: 0
      t.string :name
      t.string :phone_number, null: false
      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end
  end
end
