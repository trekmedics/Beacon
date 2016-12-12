class AddLocationToReportingParty < ActiveRecord::Migration
  def change
    add_column :reporting_parties, :location, :string
  end
end
