require 'test_helper'

class MedicalDoctorTest < ActiveSupport::TestCase
  def setup
    ApplicationConfiguration.instance.data_center = data_centers(:data_center_one)
    @hospital = hospitals(:hospital_one)
  end

  test 'medical doctor can be created successfully' do
    medical_doctor = MedicalDoctor.create(hospital: @hospital, name: 'Dr. McTestington', phone_number: '+15555550000')
    assert medical_doctor.errors.messages.blank?, 'There should be no validation errors.'
    assert medical_doctor.id.present?, 'ID should be present if medical doctor was created properly.'
  end

  test 'should not save medical doctor without hospital' do
    medical_doctor = MedicalDoctor.new(name: 'Dr. McTestington', phone_number: '+15555550001')
    assert_not medical_doctor.save, 'Saved medical doctor without hospital'
    assert medical_doctor.errors.messages[:hospital].present?, 'No validation error for hospital.'
    assert medical_doctor.errors.messages[:hospital].include?('cannot be blank.'), "Errors: #{medical_doctor.errors.messages[:hospital]}"
  end

  test 'should not save medical doctor without name' do
    medical_doctor = MedicalDoctor.new(hospital: @hospital, phone_number: '+15555550002')
    assert_not medical_doctor.save, 'Saved medical doctor without name.'
    assert medical_doctor.errors.messages[:name].present?, 'No validation error for name.'
    assert medical_doctor.errors.messages[:name].include?('cannot be blank.'), "Errors: #{medical_doctor.errors.messages[:name]}"
  end

  test 'should not save medical doctor without phone number' do
    medical_doctor = MedicalDoctor.new(hospital: @hospital, name: 'Dr. McTestington')
    assert_not medical_doctor.save, 'Saved medical doctor without phone number.'
    assert medical_doctor.errors.messages[:phone_number].present?, 'No validation error for phone number.'
    assert medical_doctor.errors.messages[:phone_number].include?('must be in E.164 format.'), "Errors: #{medical_doctor.errors.messages[:phone_number]}"
  end
end
