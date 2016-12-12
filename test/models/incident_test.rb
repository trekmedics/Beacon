require 'test_helper'

class FirstResponderTest < ActiveSupport::TestCase
  def setup
    ApplicationConfiguration.instance.data_center = data_centers(:data_center_one)
    @data_center = ApplicationConfiguration.instance.data_center
  end

  test 'fetch active incidents' do
    active_incidents = Incident.fetch_active_incidents(@data_center)
    assert active_incidents.include?(incidents(:waiting_for_location_recent))
    assert active_incidents.include?(incidents(:waiting_for_location_old))
    assert active_incidents.include?(incidents(:incident_complete_recent))
    assert_not active_incidents.include?(incidents(:incident_complete_old))
  end

  test 'set incident default values if not already set' do
    incident = Incident.new
    assert incident.number_of_frs_to_allocate == ApplicationConfiguration.instance.number_of_frs_to_allocate.to_i, "Asserting: #{incident.number_of_frs_to_allocate} == #{ApplicationConfiguration.instance.number_of_frs_to_allocate.to_i}"
    assert incident.number_of_transport_vehicles_to_allocate == ApplicationConfiguration.instance.number_of_transport_vehicles_to_allocate.to_i, "Asserting: #{incident.number_of_transport_vehicles_to_allocate} == #{ApplicationConfiguration.instance.number_of_transport_vehicles_to_allocate.to_i}"
  end

  test 'do not set incident default values if already set' do
    modified_number_of_frs_to_allocate = ApplicationConfiguration.instance.number_of_frs_to_allocate.to_i + 1
    modified_number_of_transport_vehicles_to_allocate = ApplicationConfiguration.instance.number_of_transport_vehicles_to_allocate.to_i + 1
    incident = Incident.new(number_of_frs_to_allocate: modified_number_of_frs_to_allocate,
                            number_of_transport_vehicles_to_allocate: modified_number_of_transport_vehicles_to_allocate)
    assert_not incident.number_of_frs_to_allocate == ApplicationConfiguration.instance.number_of_frs_to_allocate.to_i
    assert_not incident.number_of_transport_vehicles_to_allocate == ApplicationConfiguration.instance.number_of_transport_vehicles_to_allocate.to_i
  end

  test 'Resource Allocation Number of FRs to Allocate than or equal to Number of Transport Vehicles to Allocate' do
    good_incident = Incident.new(data_center: @data_center, number_of_frs_to_allocate: 3, number_of_transport_vehicles_to_allocate: 2)
    bad_incident = Incident.new(data_center: @data_center, number_of_frs_to_allocate: 3, number_of_transport_vehicles_to_allocate: 4)
    good_incident.save
    bad_incident.save
    assert good_incident.errors.messages.blank?, "Errors: #{good_incident.errors.messages}"
    assert bad_incident.errors.messages.present?, 'There should be a validation error.'
    assert bad_incident.errors.messages[:base].include?(I18n.t('activerecord.errors.models.incident.first_responder_count_must_be_greater_than_or_equal_to_vehicle_count'))
  end
end
