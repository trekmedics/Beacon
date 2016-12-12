class AddIsAdminToReportingParties < ActiveRecord::Migration
  def change
    add_column :reporting_parties, :is_admin, :boolean, default: false, null: false
  end
end
