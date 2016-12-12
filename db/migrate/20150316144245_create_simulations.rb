class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.integer :first_responder_count
      t.integer :incident_count
      t.integer :seed_value
      t.boolean :is_random, null: false, default: false
      t.timestamps null: false
    end
  end
end
