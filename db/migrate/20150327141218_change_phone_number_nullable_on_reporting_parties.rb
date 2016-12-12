class ChangePhoneNumberNullableOnReportingParties < ActiveRecord::Migration
  def change
    change_column_null :reporting_parties, :phone_number, true
  end
end
