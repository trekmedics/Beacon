class AddDataCenterRefToReportingParties < ActiveRecord::Migration
  def change
    add_reference :reporting_parties, :data_center, index: true
    add_foreign_key :reporting_parties, :data_centers
  end
end
