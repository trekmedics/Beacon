require 'test_helper'

class ReportingPartyTest < ActiveSupport::TestCase
  def setup
    ApplicationConfiguration.instance.data_center = data_centers(:data_center_one)
    @data_center = ApplicationConfiguration.instance.data_center
  end

  test 'phone number uniqueness for normal reporting parties' do
    reporting_party_1 = ReportingParty.new(data_center: @data_center, phone_number: '+15555550000')
    reporting_party_2 = ReportingParty.new(data_center: @data_center, phone_number: '+15555550000')
    assert reporting_party_1.save
    assert_not reporting_party_2.save
    assert reporting_party_2.errors.messages[:phone_number].include?('is already in use by another reporting party.'), "Error: #{reporting_party_2.errors.messages[:phone_number]}"
  end

  test 'nil phone number for admin is valid' do
    reporting_party_1 = ReportingParty.new(data_center: @data_center, phone_number: nil, is_admin: true)
    reporting_party_2 = ReportingParty.new(data_center: @data_center, phone_number: nil, is_admin: true)
    assert reporting_party_1.save, "Error: #{reporting_party_1.errors.messages}"
    assert reporting_party_2.save, "Error: #{reporting_party_2.errors.messages}"
  end

  test 'nil phone number for normal reporting parties is invalid' do
    reporting_party_1 = ReportingParty.new(data_center: @data_center, phone_number: nil)
    reporting_party_2 = ReportingParty.new(data_center: @data_center, phone_number: nil)
    assert_not reporting_party_1.save
    assert_not reporting_party_2.save
    assert reporting_party_1.errors.messages[:phone_number].include?('cannot be blank.'), "Error: #{reporting_party_1.errors.messages[:phone_number]}"
    assert reporting_party_2.errors.messages[:phone_number].include?('cannot be blank.'), "Error: #{reporting_party_2.errors.messages[:phone_number]}"
  end

#   test 'sign in - successful' do
#     reporting_party = reporting_parties(:signed_out)
#     assert reporting_party.state == 'inactive'
#     reporting_party.log_in!
#     assert reporting_party.state == 'available'
#   end
#
#   test 'sign in - failure' do
#     reporting_party = reporting_parties(:signed_in)
#     assert reporting_party.state == 'available'
#     reporting_partyreporting_party.log_in!
#     assert reporting_party.state == 'available'
#   end
#
#   test 'sign out - successful' do
#     reporting_party = reporting_parties(:signed_in)
#     assert reporting_party.state == 'available'
#     reporting_party.log_out!
#     assert reporting_party.state == 'inactive', msg: "State is #{reporting_party.state}."
#   end
#
#   test 'sign out - failure' do
#     reporting_party = reporting_parties(:signed_out)
#     assert reporting_party.state == 'inactive'
#     reporting_party.log_out!
#     assert reporting_party.state == 'inactive'
#   end
#
#   test 'change phone number - success' do
#     reporting_party = reporting_parties(:signed_out)
#     reporting_party.phone_number = '+15555555550'
#     assert reporting_party.save == true
#   end
#
#   test 'change phone number - failure: logged in' do
#     reporting_party = reporting_parties(:signed_in)
#     reporting_party.phone_number = '+15555555550'
#     assert reporting_party.save == false
#     assert reporting_party.errors.messages.has_key?(:phone_number), msg: "Error message keys: #{reporting_partyreporting_party.errors.messages.keys}"
#   end
end
