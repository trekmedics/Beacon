class CreateReportingParties < ActiveRecord::Migration
  def change
    create_table :reporting_parties do |t|
      t.string :phone_number, null: false
      t.integer :state, null: false, default: 0

      t.timestamps null: false
    end
    add_index :reporting_parties, :phone_number, unique: true
  end
end
