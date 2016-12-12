class RemoveUniqueConstraintOnPhoneNumberFromReportingParties < ActiveRecord::Migration
  def up
    remove_index :reporting_parties, :phone_number
    add_index :reporting_parties, :phone_number
  end

  def down
    remove_index :reporting_parties, :phone_number
    add_index :reporting_parties, :phone_number, unique: true
  end
end
