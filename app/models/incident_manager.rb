class IncidentManager
  include Singleton

# ---------------------------------------------------------------------------------------
  def process_reporting_party_message(phone_number, message)
    data_center = ApplicationConfiguration.instance.data_center
    reporting_party = ReportingParty.find_or_create_by(data_center_id: data_center.id, phone_number: phone_number, is_active: true)
    if reporting_party.valid?
      incident = reporting_party.incident
      MessageLog.log_message(incident, reporting_party, true, message)

      if message.downcase == 'disregard'
        reporting_party.is_active = false
        reporting_party.save
        incident.cancel_incident!(:rp_cancel, "Reporting Party sent 'disregard'")
        return
      end

      case incident.reporting_party.state.to_sym
      when :request_received
        handle_request_received(incident, message)
      when :waiting_for_location
        handle_location_received(incident, message)
      when :waiting_for_location_update
        handle_location_update_received(incident, message)
      else
        handle_other_reporting_party_message(incident, message)
      end
    end
  end

# ########################################################################################
  def handle_request_received(incident, message)
    data_center = DataCenter.find(incident.data_center_id)
    first_responders = FirstResponder.by_data_center(data_center).where(state: FirstResponder.states[:available])
    if first_responders.count >= ApplicationConfiguration.instance.minimum_number_of_frs.to_i
      incident.reporting_party.request_location
      incident.help_message = message
      incident.save
      incident.request_received_event!
      incident.reporting_party.request_received_event!
    else
      incident.help_message = message
      incident.save
      message_out = I18n.t('reporting_party.no_fr_available', locale: incident.reporting_party.locale)
      OutgoingMessageService.send_text(incident.reporting_party.phone_number, message_out)
      MessageLog.log_message(incident, incident.reporting_party, false, message_out)
      incident.no_first_responders_available!(:no_frs)
    end
  end

# ########################################################################################
  def handle_location_received(incident, message)
    incident.set_location(message)
    incident.reporting_party.notify_assistance_has_been_contacted
    incident.location_received_event!
    incident.reporting_party.location_received_event!
    FirstResponderManager.instance.send_help_request_to_first_responders(incident, 'msg_request_for_assistance')
  end

# ########################################################################################
  def handle_location_update_received(incident, message)
    updated_location = incident.location + '. ' + message
    incident.set_location(updated_location)
    incident.save
    incident.reporting_party.location_update_received_event!

    assistance_requests = AssistanceRequest.find_by_assigned_to_incident(incident)
    assistance_requests.each do |assistance_request|
      first_responder = FirstResponder.find(assistance_request.first_responder_id)
      message_out = I18n.t('first_responder.msg_from_rp_do_not_reply', rp_message: message, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out)

      if first_responder.state.to_sym == :enroute_to_site
        message_out = I18n.t('first_responder.msg_confirm_arrival', location: incident.location, locale: first_responder.locale)
        OutgoingMessageService.send_text(first_responder.phone_number, message_out)
        MessageLog.log_message(incident, first_responder, false, message_out)
        first_responder.received_location_update!(incident)
      end
    end
  end

# ########################################################################################
  def handle_other_reporting_party_message(incident, message)
    assistance_requests = AssistanceRequest.find_by_assigned_to_incident(incident)
    assistance_requests.each do |assistance_request|
      first_responder = FirstResponder.find(assistance_request.first_responder_id)
      message_out = I18n.t('first_responder.msg_from_rp_do_not_reply', rp_message: message, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out)
    end
  end

# ########################################################################################
  def handle_admin_created_incident(
    data_center,
    message, location,
    number_of_frs_to_allocate,
    number_of_transport_vehicles_to_allocate,
    subcategory_id
    )
    incident = Incident.new(
      data_center: data_center,
      help_message: message,
      location: location,
      number_of_frs_to_allocate: number_of_frs_to_allocate,
      number_of_transport_vehicles_to_allocate: number_of_transport_vehicles_to_allocate,
      subcategory_id: subcategory_id
      )
    if incident.save
      ReportingParty.create(
        data_center: data_center,
        incident: incident,
        state: ReportingParty.states[:stand_by],
        is_admin: true
      )
      first_responders = FirstResponder.by_data_center(data_center).where(state: FirstResponder.states[:available])
      if first_responders.count >= ApplicationConfiguration.instance.minimum_number_of_frs.to_i
        incident.request_received_event!
        incident.location_received_event!
        FirstResponderManager.instance.send_help_request_to_first_responders(incident, 'msg_request_for_assistance')
      else
        incident.no_first_responders_available!(:no_frs)
      end
    end

    return incident
  end

# ########################################################################################
  def handle_admin_reporting_party_message(incident, message)
    MessageLog.log_message(incident, incident.reporting_party, true, message)
    assistance_requests = AssistanceRequest.find_by_assigned_to_incident(incident)
    assistance_requests.each do |assistance_request|
      first_responder = FirstResponder.find(assistance_request.first_responder_id)
      message_out = I18n.t('first_responder.msg_from_rp_do_not_reply', rp_message: message, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out)

      if first_responder.state.to_sym == :enroute_to_site
        message_out = I18n.t('first_responder.msg_confirm_arrival', location: incident.location, locale: first_responder.locale)
        OutgoingMessageService.send_text(first_responder.phone_number, message_out)
        MessageLog.log_message(incident, first_responder, false, message_out)
        first_responder.received_location_update!(incident)
      end
    end
  end

# ########################################################################################
#                                                                                        #
#                              Utility methods                                           #
#                                                                                        #
# ########################################################################################

# ########################################################################################
  def request_for_assistance_window_expired(incident_id)
    incident = Incident.find(incident_id)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "Request for assistance window expired at #{Time.zone.now.utc}\n" +
      "incident.id: #{incident_id} " +
      "type: #{incident.state.to_sym}"
    if incident.incident_complete?
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Incident (#{incident_id}) was completed before the assistance window expired."
      return
    end
    if incident.state.to_sym != :waiting_for_fr_responses && incident.state.to_sym != :waiting_for_additional_resources
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Incident (#{incident_id}) not in waiting state, state: #{incident.state}"
      return
    end
    data_center = DataCenter.find_by(id: incident.data_center_id)
    ApplicationConfiguration.instance.data_center = data_center
    incident.is_accepting_first_responders = false
    incident.save!

#     Check FirstResponderIncident table for FRs with ETAs
#     Sort, then pick required number
#     Send acceptance to fastest
#     Send not needed to remainder
#     Mark remainder as state = :inactive
    AssistanceRequest.transaction do
      assistance_requests_responding = AssistanceRequest.find_responding_by_incident(incident)
#       assistance_requests_non_responding = AssistanceRequest.find_non_responding_by_incident(incident)

      num_transports_added = 0
      if assistance_requests_responding.length > 0

        fastest_time = assistance_requests_responding.first.eta
        current_time = Time.now.utc
        diff = fastest_time.to_i - current_time.to_i
        min = diff/60
        min_int = min.round.to_i
        eta = min_int.to_s

        case incident.state.to_sym
        when :waiting_for_fr_responses
          num_transports_added = frs_responded_initial_allocation(assistance_requests_responding, incident)
        when :waiting_for_additional_resources
          num_transports_added = frs_responded_additional_allocation(assistance_requests_responding, incident)
        end

        # Notify RP
        if !incident.reporting_party_id.nil? && incident.state.to_sym == :waiting_for_fr_responses
          reporting_party = ReportingParty.find(incident.reporting_party_id)
          message_out = I18n.t('reporting_party.fr_assigned', eta: eta, locale: reporting_party.locale)
          abridged_message_out = I18n.t('reporting_party.fr_assigned_abrdgd', eta: eta, locale: reporting_party.locale)
          OutgoingMessageService.send_text(reporting_party.phone_number, message_out)
          MessageLog.log_message(incident, reporting_party, false, message_out, abridged_message_out)
        end

        # Notify IC
        if !incident.incident_commander_id.nil?
          incident_commander = FirstResponder.find(incident.incident_commander_id)
          eta = 'N/A' if num_transports_added == 0
          message_out = I18n.t('incident_commander.additional_frs_assigned',
            number_added: num_transports_added,
            eta: eta,
            locale: incident_commander.locale
          )
          abridged_message_out = I18n.t('incident_commander.additional_frs_assigned_abrdgd',
            number_added: num_transports_added,
            num_transports_added: num_transports_added,
            eta: eta,
            locale: incident_commander.locale
          )
          OutgoingMessageService.send_text(incident_commander.phone_number, message_out)
          MessageLog.log_message(incident, incident_commander, false, message_out, abridged_message_out)
        end

        # If no addl resources were added and there are no remaining FRs, end incident
#         if num_transports_added == 0 && FirstResponderManager.instance.was_this_last_assigned_first_responder?(incident)
#           incident.no_first_responders_responded!(:no_addl_resources)
#         end
        if num_transports_added == 0
          FirstResponderManager.instance.was_this_last_assigned_first_responder(incident, :no_addl_resources)
        end

      else  # assistance_requests_responding.length == 0
        if AssistanceRequest.find_by_assigned_to_incident(incident).count == 0
          case incident.state.to_sym
          when :waiting_for_fr_responses
            incident.no_first_responders_responded!(:no_frs)

            # Notify RP
            if !incident.reporting_party_id.nil?
              reporting_party = ReportingParty.find(incident.reporting_party_id)
              message_out = I18n.t('reporting_party.no_fr_available', locale: reporting_party.locale)
              OutgoingMessageService.send_text(reporting_party.phone_number, message_out)
              MessageLog.log_message(incident, reporting_party, false, message_out)
              reporting_party.is_active = false
              reporting_party.save
            end
          when :waiting_for_additional_resources
            # Clear out any unanswered requests for assistance
            assistance_requests = AssistanceRequest.where(state: AssistanceRequest.states[:received_request]).where(incident_id: incident.id)
              assistance_requests.each do |assistance_request|
              assistance_request.state = :inactive
              assistance_request.save
            end
            FirstResponderManager.instance.was_this_last_assigned_first_responder(incident, :no_addl_resources)
          end
        end

        # Notify IC
        if !incident.incident_commander_id.nil?
          incident_commander = FirstResponder.find(incident.incident_commander_id)
          message_out = I18n.t('first_responder.msg_additional_resources_not_available', locale: incident_commander.locale)
          abridged_message_out = I18n.t('first_responder.msg_additional_resources_not_available_abrdgd', locale: incident_commander.locale)
          OutgoingMessageService.send_text(incident_commander.phone_number, message_out)
          MessageLog.log_message(incident, incident_commander, false, message_out, abridged_message_out)
        end
      end

      case incident.state.to_sym
      when :waiting_for_fr_responses
        incident.frs_assigned_event!
      when :waiting_for_additional_resources
        incident.additional_resources_assigned_event!
      else
        Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Invalid state: incident.state.to_sym: #{incident.state.to_sym}"
      end

    end  # transaction
  end

# ########################################################################################
#                              Utility methods                                           #
# ########################################################################################

# ########################################################################################
  def frs_responded_initial_allocation(assistance_requests, incident)
    num_responding_frs = assistance_requests.length
    num_frs_needed = incident.number_of_frs_to_allocate
    num_transport_needed = incident.number_of_transport_vehicles_to_allocate
    num_transport_assigned = 0
#     Strategy:
#     First pick the fastest etas to get num_frs_needed
#     Then count the number of transport vehicles available
#     If it is less than num_transport_needed, continue picking
#     Until num_transport are picked or responding FRs are exhausted

    for i in 0...num_frs_needed do
      break if i >= num_responding_frs
      FirstResponderManager.instance.fr_needed(incident, assistance_requests[i])
      num_transport_assigned += 1 if assistance_requests[i].transportation_mode.to_sym == :transport_vehicle
    end
    for i in num_frs_needed...num_responding_frs
      if assistance_requests[i].transportation_mode.to_sym == :transport_vehicle && num_transport_assigned < num_transport_needed
        FirstResponderManager.instance.fr_needed(incident, assistance_requests[i])
        num_transport_assigned += 1
      else
        FirstResponderManager.instance.fr_unneeded(incident, assistance_requests[i])
      end
    end
    return num_transport_assigned
  end
  # TODO: fr.unneeded responses is probably not needed her or below.

# ########################################################################################
  def frs_responded_additional_allocation(assistance_requests, incident)
    num_responding_frs = assistance_requests.length
    num_transports_needed = incident.number_of_transport_vehicles_to_allocate
    num_transports_added = 0
    assistance_requests.each do |assistance_request|
      if num_transports_added < num_transports_needed
        if assistance_request.transportation_mode.to_sym == :transport_vehicle
          FirstResponderManager.instance.fr_needed(incident, assistance_request)
          num_transports_added += 1
        else
          FirstResponderManager.instance.fr_unneeded(incident, assistance_request)
        end
      else
        FirstResponderManager.instance.fr_unneeded(incident, assistance_request)
      end
    end
    return num_transports_added
  end

# ########################################################################################
  def cleanup_after_cancel(incident, cancel_comment)
    canceling_agent = incident.get_completion_agent
    if incident.reporting_party.present?
      message_out = I18n.t('system.cancel_message',
        incident_id: incident.id, canceling_agent: canceling_agent.to_s,
        locale: incident.reporting_party.locale
      )
      OutgoingMessageService.send_text(incident.reporting_party.phone_number, message_out)
      MessageLog.log_message(incident, incident.reporting_party, false, message_out)
    end
    assistance_requests = AssistanceRequest.where(state: [AssistanceRequest.states[:assigned],AssistanceRequest.states[:responded]]).where(incident_id: incident.id)
      assistance_requests.each do |assistance_request|
      assistance_request.state = :inactive
      assistance_request.save
      first_responder = FirstResponder.find(assistance_request.first_responder.id)
      first_responder.make_available!(incident)
      message_out = I18n.t('system.cancel_message',
        incident_id: incident.id,
        canceling_agent: canceling_agent.to_s,
        locale: first_responder.locale
      ) + " \"#{cancel_comment}\""
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out)
    end
  end

# ########################################################################################
  def handle_error(incident, message, error_message)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "Not handled yet \"#{message}\"."
    OutgoingMessageService.send_text(ApplicationConfiguration.instance.admin_number, error_message)
    MessageLog.log_message(incident, first_responder, false, error_message)
  end

end

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }


