class AddLocaleToReportingParties < ActiveRecord::Migration
  def change
    add_column :reporting_parties, :locale, :string
  end
end
