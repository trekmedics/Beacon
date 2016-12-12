class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.string :name
      t.string :phone_number
      t.references :data_center, index: true
      t.timestamps null: false
    end
    add_foreign_key :administrators, :data_centers
  end
end
