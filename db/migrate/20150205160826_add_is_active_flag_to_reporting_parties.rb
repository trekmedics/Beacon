class AddIsActiveFlagToReportingParties < ActiveRecord::Migration
  def change
    add_column :reporting_parties, :is_active, :boolean, null: false, default: true
  end
end
