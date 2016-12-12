class AddDataCenterRefToSettings < ActiveRecord::Migration
  def change
    add_reference :settings, :data_center, index: true
    add_foreign_key :settings, :data_centers
  end
end
