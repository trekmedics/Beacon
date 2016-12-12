class RemoveLocationFromReportingParties < ActiveRecord::Migration
  def change
    remove_column :reporting_parties, :location, :string
  end
end
