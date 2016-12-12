# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if DataCenter.all.count == 0
  data_center = DataCenter.find_or_create_by(name: 'Develop')
  user = User.create_with(data_center: data_center, password: 'Password1', is_admin: true).find_or_create_by(username: 'admin')
end

if DataCenter.where(is_simulator: true).count == 0
  DataCenter.create(name: 'Simulator', is_simulator: true)
end


Setting.where(key: 'response_timeout').each { |k| k.destroy }
Setting.where(key: 'timeout_resend_max').each { |k| k.destroy }
Setting.where(key: 'resource_allocation_fr_eta_threshold').each { |k| k.destroy }
Setting.where(key: 'resource_allocation_fr_eta_threshold_required_vehicles').each { |k| k.destroy }

DataCenter.all.each do |data_center|
  Setting.create_with(value: 'N/A').find_or_create_by(data_center: data_center, key: 'beacon_number')
  Setting.create_with(value: 'N/A').find_or_create_by(data_center: data_center, key: 'admin_number')
  Setting.create_with(value: 'en').find_or_create_by(data_center: data_center, key: 'message_language')
  Setting.create_with(value: 'en').find_or_create_by(data_center: data_center, key: 'admin_language')
  Setting.create_with(value: '1').find_or_create_by(data_center: data_center, key: 'timeout_first_response_allocation')
  Setting.create_with(value: '3').find_or_create_by(data_center: data_center, key: 'number_of_frs_to_allocate')
  Setting.create_with(value: '1').find_or_create_by(data_center: data_center, key: 'minimum_number_of_frs')
  Setting.create_with(value: '1').find_or_create_by(data_center: data_center, key: 'number_of_transport_vehicles_to_allocate')
  Setting.create_with(value: '-04:00').find_or_create_by(data_center: data_center, key: 'utc_offset')
  Setting.create_with(value: 'true').find_or_create_by(data_center: data_center, key: 'is_white_list_enabled')
  Setting.create_with(value: 'true').find_or_create_by(data_center: data_center, key: 'is_data_center_on')
  Setting.create_with(value: 'Twilio').find_or_create_by(data_center: data_center, key: 'outgoing_message_server')
end

# Seed simulator FRs and white list simulator RPS
data_center = DataCenter.find_by(name: 'Simulator')
ApplicationConfiguration.instance.data_center = data_center
for i in 0...200 do
  digits = sprintf("%04d", i)
  phone_number = '+1800555' + digits
  name = 'zFR ' + digits
  locale = 'en'
  fr = FirstResponder.find_or_create_by(
    phone_number: phone_number,
    data_center_id: data_center.id
  )
  fr.name = name
  fr.locale = locale
  fr.save
end
for i in 9000...9020 do
  digits = sprintf("%04d", i)
  phone_number = '+1800555' + digits
  name = 'RP ' + digits
  WhiteListedPhoneNumber.create(
    phone_number: phone_number,
    name: name,
    data_center_id: data_center.id
  ) if !WhiteListedPhoneNumber.check_white_list(data_center, phone_number)
end

# Seed administrators
data_centers = DataCenter.all
data_centers.each do |data_center|
  ApplicationConfiguration.instance.data_center = data_center
  Administrator.create(
    name: 'Admin',
    phone_number: '+18005558000',
    data_center_id: data_center.id
  ) if !Administrator.find_by_data_center(data_center).present?
end

# Seed simulator hospitals
data_center = DataCenter.where(name: 'Simulator').first
ApplicationConfiguration.instance.data_center = data_center
hospital = Hospital.find_or_create_by(name: 'Hospital 1', data_center_id: data_center.id)
MedicalDoctor.find_or_create_by(hospital_id: hospital.id, name: 'Dr. Jekyll', phone_number: '+18005558001')
MedicalDoctor.find_or_create_by(hospital_id: hospital.id, name: 'Mr. Hyde', phone_number: '+18005558002')


# Seed categories and subcategories
category = Category.find_or_create_by(name: 'trauma')
Subcategory.find_or_create_by(name: 'road_traffic', category_id: category.id)
Subcategory.find_or_create_by(name: 'gunshot_stabbing', category_id: category.id)
Subcategory.find_or_create_by(name: 'fall', category_id: category.id)
Subcategory.find_or_create_by(name: 'burn', category_id: category.id)

category = Category.find_or_create_by(name: 'medical')
Subcategory.find_or_create_by(name: 'obstetric', category_id: category.id)
Subcategory.find_or_create_by(name: 'vomit', category_id: category.id)
Subcategory.find_or_create_by(name: 'unresponsive', category_id: category.id)
Subcategory.find_or_create_by(name: 'mental', category_id: category.id)
Subcategory.find_or_create_by(name: 'chest_pain', category_id: category.id)
Subcategory.find_or_create_by(name: 'breathing', category_id: category.id)
Subcategory.find_or_create_by(name: 'fever', category_id: category.id)
Subcategory.find_or_create_by(name: 'abdominal_pain', category_id: category.id)
Subcategory.find_or_create_by(name: 'seizure', category_id: category.id)

category = Category.find_or_create_by(name: 'other')
Subcategory.find_or_create_by(name: 'pediatric', category_id: category.id)
Subcategory.find_or_create_by(name: 'other', category_id: category.id)

# Seed user_roles
UserRole.find_or_create_by(name: 'Admin')
UserRole.find_or_create_by(name: 'Manager')
UserRole.find_or_create_by(name: 'Dispatcher')
UserRole.find_or_create_by(name: 'Supervisor')

# Set user_roles for existing users
admin_role_id = UserRole.find_by(name: 'Admin').id
dispatcher_role_id = UserRole.find_by(name: 'Dispatcher').id
User.all.each do |user|
  user.is_admin ? role_id = admin_role_id : role_id = dispatcher_role_id
  user.user_role_id = role_id
  user.save!
end


