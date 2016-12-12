require 'test_helper'

class HospitalTest < ActiveSupport::TestCase
  def setup
    ApplicationConfiguration.instance.data_center = data_centers(:data_center_one)
    @data_center = ApplicationConfiguration.instance.data_center
  end

  test 'hospital can be created successfully' do
    hospital = Hospital.create(data_center: @data_center, name: 'Test Hospital')
    assert hospital.errors.messages.blank?, 'There should be no validation errors.'
    assert hospital.id.present?, 'ID should be present if hospital was created properly.'
  end

  test 'must belong to a data center' do
    hospital = Hospital.create(name: 'Test Hospital')
    assert hospital.errors.messages.present?, 'There should be a validation error.'
    assert hospital.errors.messages[:data_center].include?('cannot be blank.'), "Error: #{hospital.errors.messages[:data_center]}"
    assert hospital.id.blank?, 'ID should not be present if the hospital was not created.'
  end

  test 'must have a name' do
    hospital = Hospital.create(data_center: @data_center)
    assert hospital.errors.messages.present?, 'There should be a validation error.'
    assert hospital.errors.messages[:name].include?('cannot be blank.'), "Error: #{hospital.errors.messages[:name]}"
    assert hospital.id.blank?, 'ID should not be present if the hospital was not created.'
  end
end
