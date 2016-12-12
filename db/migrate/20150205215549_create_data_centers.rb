class CreateDataCenters < ActiveRecord::Migration
  def change
    create_table :data_centers do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
