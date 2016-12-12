test_usage = <<-END.gsub(/^{4}/, '')
  Usage bundle exec rails r ./test/integration/irb_test.rb 

Sections
  0:  Create incident
      Provide ETAs (FR 0, FR 1, FR 2)

  1:  First arrival on site (FR 0, FR 1, FR 2)
      Reply to Need Addl Help (FR 0)
      Reply to Transport Request (FR 0, FR 1, FR 2)
      Arrive at hospital (FR 0, FR 1, FR 2)
      Reply to Addl Help needed (FR 3, FR 4)

  2:  Arrive on scene (FR 3, FR 4)
      Reply to transport (FR 3, FR 4)
      Arrive at hospital (FR 3, FR 4)

  9: Close incident, logout (FR 0, FR 1, FR 2, FR 3, FR 4)

 10: Transient test code

  and where dddd is last four digits of RP phone number (+1800555 will be prepended)
  Help message will be Help dddd
  Location message will be Loc dddd

  Example:
  bundle exec rails r ./test/integration/irb_test.rb 9000 0

END

if ARGV.count != 0

  puts test_usage
  exit
end

data_center = DataCenter.find_by_name('Simulator')
ApplicationConfiguration.instance.data_center = data_center

max_number_of_frs = 10
frs = FirstResponder.where(data_center_id: data_center.id).where.not(state: FirstResponder.states[:disabled]).limit(max_number_of_frs).order(:name)

help_message = 'no_hospital'
location     = 'no_hospital'
rp_phone_number = '+18005559000'

  # Clear hospitals and doctors

Hospital.where(data_center_id: data_center.id).each { |h| h.destroy }

case ARGV[1].to_i

# ###################################################################################### #
when 0

# Login and set transport
  frs.each do |fr|
    fr.log_out!
  end

  # Log in
  IncomingMessageService.process_message(frs[0].phone_number,'123')
  IncomingMessageService.process_message(frs[1].phone_number,'123')
  IncomingMessageService.process_message(frs[2].phone_number,'123')
  IncomingMessageService.process_message(frs[3].phone_number,'123')
#   IncomingMessageService.process_message(frs[4].phone_number,'123')
#   IncomingMessageService.process_message(frs[5].phone_number,'123')
#   IncomingMessageService.process_message(frs[6].phone_number,'123')
#   IncomingMessageService.process_message(frs[7].phone_number,'123')

  #Set transportation∫
  IncomingMessageService.process_message(frs[0].phone_number, '3')
  IncomingMessageService.process_message(frs[1].phone_number, '3')
  IncomingMessageService.process_message(frs[2].phone_number, '3')
  IncomingMessageService.process_message(frs[3].phone_number, '3')
#   IncomingMessageService.process_message(frs[4].phone_number, '3')
#   IncomingMessageService.process_message(frs[5].phone_number, '3')
#   IncomingMessageService.process_message(frs[6].phone_number, '3')
#   IncomingMessageService.process_message(frs[7].phone_number, '3')

# Create incident
  IncomingMessageService.process_message(rp_phone_number, help_message)
  IncomingMessageService.process_message(rp_phone_number, location)

#   IncomingMessageService.process_message(rp_phone_number, 'Unexpected RP message 0')

  rp = ReportingParty.find_by_phone_number(rp_phone_number)
  exit if rp.nil?

# Set number of FRs and number of Vehicles desired
  incident = Incident.find_by_reporting_party_id(rp.id)
  incident.number_of_frs_to_allocate = 2
  incident.number_of_transport_vehicles_to_allocate = 1
  incident.save

# Some respond promptly
  IncomingMessageService.process_message(frs[0].phone_number, incident.id.to_s + '.5')
  IncomingMessageService.process_message(frs[1].phone_number, incident.id.to_s + '.10')
  IncomingMessageService.process_message(frs[2].phone_number, incident.id.to_s + '.15')
  IncomingMessageService.process_message(frs[3].phone_number, incident.id.to_s + '.15')
#   IncomingMessageService.process_message(frs[4].phone_number, incident.id.to_s + '.15')
#   IncomingMessageService.process_message(frs[5].phone_number, incident.id.to_s + '.15')

# Expire Assistance Request window manually
  IncidentManager.instance.request_for_assistance_window_expired(incident.id)

  puts "\tPart 0: incident.id: #{incident.id}"

# ###################################################################################### #
# when 1

#   rp = ReportingParty.find_by_phone_number(rp_phone_number)
#   exit if rp.nil?
#   incident = Incident.find_by_reporting_party_id(rp.id)

#   IncomingMessageService.process_message(rp_phone_number, 'Unexpected RP message 1')


  # Arrives at location (1) or cancels (0) or cannot locate (2)
  IncomingMessageService.process_message(frs[0].phone_number, '1')
  IncomingMessageService.process_message(frs[1].phone_number, '1')

#   RP provides more location info
#   IncomingMessageService.process_message(rp_phone_number, 'More location info')
#   IncomingMessageService.process_message(frs[1].phone_number, '1')

  # IC responds to addl vehicles needed question or not
  IncomingMessageService.process_message(frs[0].phone_number, '0')

#   Responds late
#   IncomingMessageService.process_message(frs[2].phone_number, incident.id.to_s + '.15')
#
  # Responds to transport question
  IncomingMessageService.process_message(frs[0].phone_number, '1.5')
  IncomingMessageService.process_message(frs[1].phone_number, '0')
#   IncomingMessageService.process_message(frs[2].phone_number, '1.1.15')

# Responds to needs addl help request
#   IncomingMessageService.process_message(frs[2].phone_number, incident.id.to_s + '.5')
#   IncomingMessageService.process_message(frs[3].phone_number, incident.id.to_s + '.5')
#   IncomingMessageService.process_message(frs[4].phone_number, incident.id.to_s + '.10')
#   IncomingMessageService.process_message(frs[5].phone_number, incident.id.to_s + '.15')

  # Arrives at hospital
  IncomingMessageService.process_message(frs[0].phone_number, '1')
#   IncomingMessageService.process_message(frs[1].phone_number, '0')
#   IncomingMessageService.process_message(frs[2].phone_number, '1')

# Expire Assistance Request window manually
  IncidentManager.instance.request_for_assistance_window_expired(incident.id)

# Seed simulator hospitals
  data_center = DataCenter.where(name: 'Simulator').first
  ApplicationConfiguration.instance.data_center = data_center
  hospital = Hospital.create(name: 'Hospital 1', data_center_id: data_center.id)
  MedicalDoctor.find_or_create_by(hospital_id: hospital.id, name: 'Dr. Jekyll', phone_number: '+18005558000')
  MedicalDoctor.find_or_create_by(hospital_id: hospital.id, name: 'Mr. Hyde', phone_number: '+18005558001')

  puts "\tPart 1: incident.id: #{incident.id}"

# ###################################################################################### #
# when 2

#   rp = ReportingParty.find_by_phone_number(rp_phone_number)
#   exit if rp.nil?
#   incident = Incident.find_by_reporting_party_id(rp.id)

#   IncomingMessageService.process_message(rp_phone_number, 'Unexpected RP message 2')

  # Arrives at location or cancels
#   IncomingMessageService.process_message(frs[2].phone_number, '1')
#   IncomingMessageService.process_message(frs[3].phone_number, '1')
#   IncomingMessageService.process_message(frs[4].phone_number, '1')
#   IncomingMessageService.process_message(frs[5].phone_number, '1')

  # Responds to needs addl help request
#   IncomingMessageService.process_message(frs[2].phone_number, '0')

  # Responds to transport question
#   IncomingMessageService.process_message(frs[2].phone_number, '1.1.5')
#   IncomingMessageService.process_message(frs[3].phone_number, '1.1.5')
#   IncomingMessageService.process_message(frs[4].phone_number, '1.1.10')
#   IncomingMessageService.process_message(frs[5].phone_number, '1.1.10')

  # Arrives at hospital
#   IncomingMessageService.process_message(frs[2].phone_number, '1')
#   IncomingMessageService.process_message(frs[3].phone_number, '1')
#   IncomingMessageService.process_message(frs[4].phone_number, '1')
#   IncomingMessageService.process_message(frs[5].phone_number, '1')

  # Arrives at hospital
#   IncomingMessageService.process_message(frs[4].phone_number, '1')

  # Responds to needs addl help request late
#   IncomingMessageService.process_message(frs[5].phone_number, incident.id.to_s + '.15')

# Expire Assistance Request window manually
#   IncidentManager.instance.request_for_assistance_window_expired(incident.id)

  puts "\tPart 2: incident.id: #{incident.id}"

# ###################################################################################### #
# when 3

#   rp = ReportingParty.find_by_phone_number(rp_phone_number)
#   exit if rp.nil?
#   incident = Incident.find_by_reporting_party_id(rp.id)

#   IncomingMessageService.process_message(rp_phone_number, 'Unexpected RP message 2')

  # Arrives at location or cancels
#   IncomingMessageService.process_message(frs[3].phone_number, '1')
#   IncomingMessageService.process_message(frs[4].phone_number, '1')
#   IncomingMessageService.process_message(frs[5].phone_number, '1')

  # Responds to needs addl help request
#   IncomingMessageService.process_message(frs[4].phone_number, '1')

  # Responds to transport question
#   IncomingMessageService.process_message(frs[3].phone_number, '1.1.5')
#   IncomingMessageService.process_message(frs[4].phone_number, '1.1.10')
#   IncomingMessageService.process_message(frs[5].phone_number, '1.1.10')

  # Arrives at hospital
#   IncomingMessageService.process_message(frs[1].phone_number, '1')
#   IncomingMessageService.process_message(frs[3].phone_number, '1')
#   IncomingMessageService.process_message(frs[4].phone_number, '1')
#   IncomingMessageService.process_message(frs[5].phone_number, '1')

  # Arrives at hospital
#   IncomingMessageService.process_message(frs[4].phone_number, '1')
# Responds to needs addl help request late
#   IncomingMessageService.process_message(frs[5].phone_number, incident.id.to_s + '.15')

  # Expire Assistance Request window manually
#   IncidentManager.instance.request_for_assistance_window_expired(incident.id)

  # Late response
#   IncomingMessageService.process_message(frs[2].phone_number,  incident.id.to_s + '.15')

  puts "\tPart 3: incident.id: #{incident.id}"

# ###################################################################################### #
# when 9

frs = FirstResponder.where(data_center_id: data_center.id).where.not(state: FirstResponder.states[:disabled]).limit(max_number_of_frs).order(:phone_number)
  frs.each do |fr|
    IncomingMessageService.process_message(fr.phone_number,'456')
  end

#   rp = ReportingParty.find_by_phone_number(rp_phone_number)
#   if !rp.present?
#     puts "\tPart 9: no active RP"
#     exit
#   else
#   end

  incident = Incident.find_by_reporting_party_id(rp.id)

  test_label = 'no_hospital'
if incident.state == 'incident_complete' && incident.completion_status == 'normal'
  puts "Passed #{test_label}: #{incident.id}"
else
  puts "Failed #{test_label}: #{incident.id}"
  puts "\tstate:             #{incident.state.to_i} - #{incident.state}"
  puts "\tcompletion_status: #{incident.completion_status.to_i} - #{incident.completion_status}"
end

rp.is_active = false
  rp.save

  incident.cancel_incident!(:normal, 'Test')

  puts "\tPart 9: incident.id: #{incident.id}"

# ###################################################################################### #
when 10

  sim = Simulation.last
  sim.run

  puts "\tPart 10: sim.id: #{sim.id}"

# ###################################################################################### #
when 11

  puts "Counts:"
  puts sprintf("%5d %s", Administrator.all.count, "Administrator")
  puts sprintf("%5d %s", AssistanceRequest.all.count, "AssistanceRequest")
  puts sprintf("%5d %s", DataCenterPermission.all.count, "DataCenterPermission")
  puts sprintf("%5d %s", DataCenter.all.count, "DataCenter")
  puts sprintf("%5d %s", FirstResponderEventLog.all.count, "FirstResponderEventLog")
  puts sprintf("%5d %s", FirstResponderPerformanceDatum.all.count, "FirstResponderPerformanceDatum")
  puts sprintf("%5d %s", FirstResponder.all.count, "FirstResponder")
  puts sprintf("%5d %s", Hospital.all.count, "Hospital")
  puts sprintf("%5d %s", IncidentEventLog.all.count, "IncidentEventLog")
  puts sprintf("%5d %s", Incident.all.count, "Incident")
  puts sprintf("%5d %s", MedicalDoctor.all.count, "MedicalDoctor")
  puts sprintf("%5d %s", MessageLog.all.count, "MessageLog")
  puts sprintf("%5d %s", ReportingParty.all.count, "ReportingParty")
  puts sprintf("%5d %s", Simulation.all.count, "Simulation")
  puts sprintf("%5d %s", User.all.count, "Users")
  puts sprintf("%5d %s", WhiteListedPhoneNumber.all.count, "WhiteListedPhoneNumber")

  puts ''
  puts "Deleted:"
  puts sprintf("%5d %s", AssistanceRequest.delete_all, "AssistanceRequest")
  puts sprintf("%5d %s", FirstResponderEventLog.delete_all, "FirstResponderEventLog")
  puts sprintf("%5d %s", FirstResponderPerformanceDatum.delete_all, "FirstResponderPerformanceData")
  puts sprintf("%5d %s", IncidentEventLog.delete_all, "IncidentEventLog")
  puts sprintf("%5d %s", Incident.delete_all, "Incidents")
  puts sprintf("%5d %s", MessageLog.delete_all, "MessageLog")
  puts sprintf("%5d %s", ReportingParty.delete_all, "ReportingParty")

  puts "\tPart 11"





else
# ##################################################
#     '0: Create incident; Provide ETAs',
#     '1: First arrival on site',
#     '2: Later arrival on site',
#     '3: Respond to request for additional help',
#     '4: Respond to request about transporting',
#     '5: Arrive at hospital',
#     '9: Close incident, logout',
#    '10: Transient test code'
  puts "Case #{ARGV[1]} does not exist"
end




# Ruby on Rails/Angular commands
#
# export BEACON_TWILIO_ACCOUNT_SID=''
# export BEACON_TWILIO_AUTH_TOKEN=''
# export BEACON_TWILIO_PHONE_NUMBER='+5213315455302'
#
# bundle exec rake test:models RAILS_ENV=test
# bundle exec rake test:integration RAILS_ENV=test
# rails g scaffold_controller setting
#
# bundle exec rake websocket_rails:stop_server
# bundle exec rake websocket_rails:start_server
#
# bundle exec rails g migration add_eta_to_first_responder_incidents eta:integer
# bundle exec rails g migration add_current_to_first_responder_incidents current:boolean
#
# bundle exec rake bower:install
#
# bundle
# bundle install
# bundle exec rake db:migrate
# bundle exec rake db:seed
# bundle exec foreman start
# bundle exec rake test RAILS_ENV=test
# bundle exec rake test:integration RAILS_ENV=test
# bundle exec rake assets:precompile   (In production environment, if anything changes in app/assets)
# bundle exec rails g model Incident reporting_party:references location:string
# bundle exec rails g scaffold_controller setting
# bundle exec rake websocket_rails:start_server
# bundle exec rake websocket_rails:stop_server

# gem pristine --all
#
# bundle exec rails console
# bundle exec rails runner ./test/integration/irb_test.rb
#
# redis-server
#
# Rails.logger.debug "message: #{@I18n.t('first_responder.response_vehicle').inspect}"
#
# f.errors
#
#
# http://localhost:5000/resque
#
# http://beacon.vpsapp.net/incoming_messages
# http://localhost:5000/incoming_messages
# curl --data From=%2B18005559000&Body=Help+9000&To=%2B19177463864 http://localhost:5000/incoming_messages
# curl --data From=%2B18005559000&Body=Loci+9000&To=%2B19177463864 http://localhost:5000/
#
#
# egrep -A3 "^\[" log/development.log | tail -n 50

# ssh -i ../BeaconProduction.pem.txt ubuntu@52.4.133.252

# scp -i ../BeaconProduction.pem.txt ../dispatch_trekmedics_org/dispatch_ssl_bundle.crt ubuntu@52.4.133.252:~


