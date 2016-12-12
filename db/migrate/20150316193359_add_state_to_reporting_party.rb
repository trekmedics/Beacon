class AddStateToReportingParty < ActiveRecord::Migration
  def change
    add_column :reporting_parties, :state, :integer, null: false, default: 0
  end
end
