class RemoveStateFromReportingParties < ActiveRecord::Migration
  def change
    remove_column :reporting_parties, :state, :integer, null: false, default: 0
  end
end
