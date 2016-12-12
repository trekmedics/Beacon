class CreateHospitals < ActiveRecord::Migration
  def change
    create_table :hospitals do |t|
      t.references :data_center, index: true
      t.string :name
      t.timestamps null: false
    end
    add_foreign_key :hospitals, :data_centers
  end
end
