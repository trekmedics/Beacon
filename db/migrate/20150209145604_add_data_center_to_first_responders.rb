class AddDataCenterToFirstResponders < ActiveRecord::Migration
  def change
    add_reference :first_responders, :data_center, index: true
    add_foreign_key :first_responders, :data_centers
  end
end
