class Simulation < ActiveRecord::Base
  after_create :schedule_simulation

  validates :first_responder_count, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2000 }
  validates :incident_count, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 200 }

  def run
    Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n" +
      "*********** Start simulation run ***********"
    data_center = DataCenter.find_by(name: 'Simulator')
    ApplicationConfiguration.instance.data_center = data_center

    first_responders = get_first_responders(data_center)

    clear_old_simulations(data_center, first_responders)

    first_responders_log_in(data_center, first_responders)

    incidents = start_incidents(data_center)

    first_responders_respond(first_responders, incidents)

    expire_request_for_assistance_windows(incidents)

    first_responders_arrive_on_scene(incidents)

    first_responders_indicate_transport(incidents)

    first_responders_arrive_at_hospital(incidents)

    first_responders_log_out(first_responders)

  end

# ########################################################################################
  def clear_old_simulations(data_center, first_responders)
    first_responders.each do |fr|
      fr.log_out!
    end
    incidents = Incident.where.not(state: Incident.states[:incident_complete])
    incidents.each do |inc|
#       inc.cancel_incident!(:admin_cancel, 'message')
      inc.end_incident!(:admin_cancel)
      puts inc.id
    end
    reporting_parties = ReportingParty.where(is_active: true)
    reporting_parties.each do |rp|
      rp.is_active = false
      rp.save!
    end
  end

# ########################################################################################
  def expire_request_for_assistance_windows(incidents)
#   Expire Assistance Request window manually
    incidents.each do |incident|
      IncidentManager.instance.request_for_assistance_window_expired(incident.id)
    end
  end

# ########################################################################################
  def first_responders_arrive_on_scene(incidents)
#   Expire Assistance Request window manually
    incidents.each do |incident|
      puts 'incident.id: ',incident.id
      assistance_requests = AssistanceRequest.where(incident_id: incident.id, state: AssistanceRequest.states[:assigned])
      first = true
      assistance_requests.each do |assistance_request|
        puts 'first_responder.id: ',assistance_request.first_responder.id
        IncomingMessageService.process_message(assistance_request.first_responder.phone_number, '1')
#       Respond to IC query about additional resources
        if first
          IncomingMessageService.process_message(assistance_request.first_responder.phone_number, '0')
          first = false
        end
      end
    end
  end

# ########################################################################################
  def first_responders_indicate_transport(incidents)
    incidents.each do |incident|
      assistance_requests = AssistanceRequest.where(incident_id: incident.id, state: AssistanceRequest.states[:assigned])
      assistance_requests.each do |assistance_request|
        IncomingMessageService.process_message(assistance_request.first_responder.phone_number, '1.2.5')
      end
    end
  end

# ########################################################################################
  def first_responders_arrive_at_hospital(incidents)
    incidents.each do |incident|
      assistance_requests = AssistanceRequest.where(incident_id: incident.id, state: AssistanceRequest.states[:assigned])
      assistance_requests.each do |assistance_request|
        IncomingMessageService.process_message(assistance_request.first_responder.phone_number, '1')
      end
    end
  end

# ########################################################################################
  def first_responders_log_in(data_center, first_responders)
    for i in 0...first_responders.length
      first_responders[i].log_out!
      phone_number = first_responders[i].phone_number
      IncomingMessageService.process_message(phone_number, '123')
      IncomingMessageService.process_message(phone_number, '3')
    end
    first_responders = get_first_responders(data_center)
    return first_responders
  end

# ########################################################################################
  def first_responders_log_out(first_responders)
    for i in 0...first_responders.length
      IncomingMessageService.process_message(first_responders[i].phone_number, '456')
    end
  end

# ########################################################################################
  def first_responders_respond(first_responders, incidents)
    for i in 0...first_responders.length
      for j in 0...incidents.length
        message = incidents[j].id.to_s + '.5'
        IncomingMessageService.process_message(first_responders[i].phone_number, message)
      end
    end
  end

# ########################################################################################
  def get_first_responders(data_center)
    first_responders = FirstResponder.where.not(state: FirstResponder.states[:inactive]).where(data_center_id: data_center.id).order(:name)
    return first_responders
  end

# ########################################################################################
  def start_incidents(data_center)
    ApplicationConfiguration.instance.data_center = data_center
    incidents = []
    for i in 9000...(9000+self.incident_count)
      digits = sprintf("%04d", i)
      phone_number = '+1800555' + digits
      help_message = 'Help ' + digits
      location = 'Location ' + digits
      IncomingMessageService.process_message(phone_number, help_message)
      IncomingMessageService.process_message(phone_number, location)
      reporting_party = ReportingParty.find_by_phone_number(phone_number)
      incident = Incident.find_by_reporting_party_id(reporting_party.id)
      incidents << incident
      puts "incident.id: ", incident.id
    end
    return incidents
  end

private

  def get_first_responders(data_center)
    first_responders = FirstResponder.where(data_center_id: data_center.id).where.not(state: FirstResponder.states['disabled']).limit(self.first_responder_count)
    return first_responders
  end

  def schedule_simulation
    ResqueService.schedule_simulation(self)
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
