class CreateMedicalDoctors < ActiveRecord::Migration
  def change
    create_table :medical_doctors do |t|
      t.references :hospital, index: true
      t.string :name
      t.string :phone_number
      t.timestamps null: false
    end
    add_foreign_key :medical_doctors, :hospitals
  end
end
