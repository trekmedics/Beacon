class AddDataCenterRefToIncidents < ActiveRecord::Migration
  def change
    add_reference :incidents, :data_center, index: true
    add_foreign_key :incidents, :data_centers
  end
end
