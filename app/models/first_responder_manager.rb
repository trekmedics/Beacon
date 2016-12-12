class FirstResponderManager
  include Singleton

# ########################################################################################
  def process_first_responder_message(first_responder, message)

    # Remove leading and trailing white space
    message = message.to_s.strip

    if message == '456'
      MessageLog.log_message(nil, first_responder, true, message)
      first_responder.log_out!
      return
    end
    case first_responder.state.to_sym
    when :inactive
      self.handle_inactive(first_responder, message)
    when :setting_transport_mode
      self.handle_setting_transport_mode(first_responder, message)
    when :available
      self.handle_available(first_responder, message)
    when :enroute_to_site
      self.handle_enroute_to_site(first_responder, message)
    when :is_incident_commander_on_site
      self.handle_ic_response_to_addl_request(first_responder, message)
    when :on_site
      self.handle_on_site(first_responder, message)
    when :transporting
      self.handle_transporting(first_responder, message)
    else
      self.handle_error(first_responder, nil, message, "[#{__LINE__}] State not handled.")
    end
  end







# ########################################################################################
#      Handle incoming FR messages methods (ordered by position in message flow)         #
# ########################################################################################

# ########################################################################################
  def handle_inactive(first_responder, message)
    MessageLog.log_message(nil, first_responder, true, message)

    if message == '123'
      message_out = I18n.t('first_responder.response_vehicle',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        locale: first_responder.locale
      )
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(nil, first_responder, false, message_out)
      first_responder.log_in!
    else
      message_out = I18n.t('first_responder.msg_invalid_login_message', last_message: message, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(nil, first_responder, false, message_out)
    end
  end

# ########################################################################################
  def handle_setting_transport_mode(first_responder, message)
    MessageLog.log_message(nil, first_responder, true, message)

    if validate_message?(message) && (1..3).include?(message.to_i)
      first_responder.set_transportation_mode(message.to_i)

      transportation_mode = I18n.t("first_responder.transportation_mode.modes.#{first_responder.transportation_mode}", locale: first_responder.locale)
      message_out = I18n.t('first_responder.transportation_mode.configured_message', transportation_mode: transportation_mode, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(nil, first_responder, false, message_out)
      first_responder.set_transport_mode!
    else
      handle_unknown_response(__LINE__, nil, first_responder, message)
    end
  end

# ########################################################################################
  def handle_available(first_responder, message)

#       Responding?:
#       Yes: %{incident_id}.MINS
    message_elements = message.split('.')

    # Check that incident exists:
    incident_id = message_elements[0]
    incident = Incident.find_by(id: incident_id)
    if incident.nil?
      MessageLog.log_message(incident, first_responder, true, message, '', :request_for_assistance_reply)
      handle_unknown_response(__LINE__, incident, first_responder, message)
      return
    end

    # Check that message has two parts and is all numbers
    if not validate_message?(message) || message_elements.count != 2
      MessageLog.log_message(nil, first_responder, true, message)
      handle_unknown_response(__LINE__, incident, first_responder, message)
      return
    end


    # Check that current FirstResponderIncident record exists:
    assistance_request = AssistanceRequest.find_by_first_responder_and_incident(first_responder, incident)
    if assistance_request.nil?
      MessageLog.log_message(nil, first_responder, true, message)
      handle_unknown_response(__LINE__, incident, first_responder, message)
      return
    end

    # Incident exists and there is a request for assistance: log message
    MessageLog.log_message(incident, first_responder, true, message, '', :request_for_assistance_reply)
    if incident.is_accepting_first_responders         # Response window is open
      eta = message_elements[1]
      arrival_time = Time.now.utc + 60*eta.to_i
      assistance_request.set_eta(arrival_time)
      assistance_request.state = :responded
      assistance_request.save
      FirstResponderPerformanceDatum.request_for_assistance_reply(assistance_request.first_responder, assistance_request.incident, eta)
    else                                              # Response window has closed
      fr_unneeded(incident, assistance_request)
    end
    # No state change, no responses
  end

# ########################################################################################
  def handle_enroute_to_site(first_responder, message)
    (assistance_request, incident) = get_assistance_request_and_log_message(first_responder, message)
    return if assistance_request.nil? || incident.nil?

#       Confirm arrival on-scene:
#       Yes: 1
#       Unable To Locate: 2
#       Cancel Response: 0

    case message
    when '0'  # Cancel FR involvement in incident
      assistance_request.deactivate!
      first_responder.make_available!(incident)
      construct_and_send_status_available(first_responder, incident)
#       incident.end_incident!(:fr_cancel) if was_this_last_assigned_first_responder?(incident)
      was_this_last_assigned_first_responder(incident, :fr_cancel)
      FirstResponderPerformanceDatum.cancel_message(first_responder, incident)
    when '1'  # On site - check if first on site or not
      ic_or_not(first_responder, message)
    when '2'  # Cannot locate
      incident.reporting_party.location_update_requested_event!
       first_responder.cannot_locate!(incident)

      # Request location update from RP
      message_out = I18n.t('reporting_party.location_update_requested', locale: incident.reporting_party.locale)
      OutgoingMessageService.send_text(incident.reporting_party.phone_number, message_out)
      MessageLog.log_message(incident, incident.reporting_party, false, message_out)

      # Copy admin on location update request
      administrators = Administrator.find_by_data_center(incident.data_center)
      if administrators.present?
        message_admin = incident.data_center.name + "\n" + I18n.t('admin.location_update_requested',
          incident_number: incident.id,
          first_responder_name: first_responder.name,
          first_responder_phone_number: first_responder.phone_number,
          locale: ApplicationConfiguration.instance.admin_language
        )
        abridged_message_admin = incident.data_center.name + "\n" + I18n.t('admin.location_update_requested_abrdgd',
          incident_number: incident.id,
          first_responder_name: first_responder.name,
          first_responder_phone_number: first_responder.phone_number,
          locale: ApplicationConfiguration.instance.admin_language
        )
        administrators.each do |administrator|
          if administrator.phone_number.present?
            OutgoingMessageService.send_text(administrator.phone_number, message_admin)
          end
          if administrator.email.present?
#             EmailService.send(administrator, 'Request for Location Update - Admin copy', message_admin)
          end
          MessageLog.log_message(incident, administrator, false, message_admin, abridged_message_admin)
        end
      end

      # Tell FR to standby and repeat confirm arrival message
      message_out =
        I18n.t('first_responder.msg_standby', locale: first_responder.locale) +
        I18n.t('first_responder.msg_confirm_arrival', location: incident.location, locale: first_responder.locale)
      abridged_message_out =
        I18n.t('first_responder.msg_standby', locale: first_responder.locale) +
        I18n.t('first_responder.msg_confirm_arrival_abrdgd', location: incident.location, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
    else
      handle_unknown_response(__LINE__, incident, first_responder, message)
    end
  end

# ########################################################################################
  def handle_ic_response_to_addl_request(first_responder, message)
    (assistance_request, incident) = get_assistance_request_and_log_message(first_responder, message)
    return if assistance_request.nil? || incident.nil?

    if !validate_message?(message) || !validate_message_no_periods?(message)
      handle_unknown_response(__LINE__, incident, first_responder, message)
      return
    end

#       Yes: #VEHICLES
#       No: 0
    if message.to_i == 0
      construct_and_send_hospital_text(first_responder, incident)
      first_responder.ic_on_site!(incident)
    elsif message.to_i > 0
      incident.number_of_transport_vehicles_to_allocate = message.to_i
      incident.save
      send_help_request_to_first_responders(incident, 'msg_request_additional_resources')
      construct_and_send_hospital_text(first_responder, incident)
      first_responder.ic_on_site!(incident)
      FirstResponderPerformanceDatum.requested_resources(first_responder, incident, message.to_i)
    else
      handle_unknown_response(__LINE__, incident, first_responder, message)
    end
  end

# ########################################################################################
  def handle_on_site(first_responder, message)
    (assistance_request, incident) = get_assistance_request_and_log_message(first_responder, message)
    return if assistance_request.nil? || incident.nil?

    if !validate_message?(message)
      handle_unknown_response(__LINE__, incident, first_responder, message)
      return
    end

#       Confirm Transport and ETA:
#       1:.#PATIENTS.#ETA
#       2:.#PATIENTS.#ETA
#       No Transport: 0
    message_elements = message.split('.')
    case message_elements.length
    when 1 # No transport
      if message_elements[0].to_i == 0
        assistance_request.deactivate!
        first_responder.arrived_at_hospital!
        construct_and_send_status_available(first_responder, incident)
#         incident.end_incident!(:fr_cancel) if was_this_last_assigned_first_responder?(incident) && !incident.is_accepting_first_responders
        was_this_last_assigned_first_responder(incident, :fr_cancel)
        number_of_patients = message_elements[1].to_i
        hospital_eta = message_elements[2].to_i
        FirstResponderPerformanceDatum.no_transport(first_responder, incident)
      else
        handle_unknown_response(__LINE__, incident, first_responder, message)
      end

    when 2 # Transport patients.eta, but no hospital
      hospitals = Hospital.find_by_data_center(incident.data_center)
      if hospitals.length == 0
        message_out = I18n.t('first_responder.msg_confirm_hospital_arrival', locale: first_responder.locale)
        abridged_message_out = I18n.t('first_responder.msg_confirm_hospital_arrival_abrdgd', locale: first_responder.locale)
        OutgoingMessageService.send_text(first_responder.phone_number, message_out)
        MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
        first_responder.is_transporting!(incident)
        FirstResponderPerformanceDatum.confirmed_transport(first_responder, incident, nil, number_of_patients, hospital_eta)
      else
        handle_unknown_response(__LINE__, incident, first_responder, message)
      end


    when 3 # Transport hospital.patients.eta
      hospitals = Hospital.find_by_data_center(incident.data_center)
      hospital_number = message_elements[0].to_i
      if hospital_number <= hospitals.count
        message_out = I18n.t('first_responder.msg_confirm_hospital_arrival', locale: first_responder.locale)
        abridged_message_out = I18n.t('first_responder.msg_confirm_hospital_arrival_abrdgd', locale: first_responder.locale)
        OutgoingMessageService.send_text(first_responder.phone_number, message_out)
        MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
        first_responder.is_transporting!(incident)

        number_of_patients = message_elements[1].to_i
        hospital_eta = message_elements[2].to_i
        assistance_request.hospital = hospitals[hospital_number-1]
        assistance_request.save
        FirstResponderPerformanceDatum.confirmed_transport(first_responder, incident, hospitals[hospital_number - 1], number_of_patients, hospital_eta)

        message_out = I18n.t(
          'oncall_md.msg_incoming_notice',
          number_patients: number_of_patients,
          first_responder_name: first_responder.name,
          first_responder_number: first_responder.phone_number,
          minutes_to_arrival: hospital_eta,
          incident_type: incident.subcategory_string,
          locale: ApplicationConfiguration.instance.admin_language
        )
        abridged_message_out = I18n.t(
          'oncall_md.msg_incoming_notice_abrdgd',
          number_patients: number_of_patients,
          first_responder_name: first_responder.name,
          first_responder_number: first_responder.phone_number,
          minutes_to_arrival: hospital_eta,
          incident_type: incident.subcategory_string,
          locale: ApplicationConfiguration.instance.admin_language
        )
        send_message_to_oncall_mds(incident, message_out, abridged_message_out, hospitals[hospital_number - 1])
      else
        handle_unknown_response(__LINE__, incident, first_responder, message)
      end

    end
  end

# ########################################################################################
  def handle_transporting(first_responder, message)
    (assistance_request, incident) = get_assistance_request_and_log_message(first_responder, message)
    return if assistance_request.nil? || incident.nil?

    if !validate_message?(message)
      handle_unknown_response(__LINE__, incident, first_responder, message)
      return
    end

    message_elements = message.split('.')
#       Confirm arrival at hospital:
#       Yes: 1
#       Need Assistance: 2
#       Delay: 3.MINS
#       Cancel: 0

    case message_elements[0].to_i
    when 0
      message_out = I18n.t('oncall_md.msg_response_cancel',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        locale: first_responder.locale
      )
      abridged_message_out = I18n.t('oncall_md.msg_response_cancel_abrdgd',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        locale: first_responder.locale
      )
      send_message_to_oncall_mds(incident, message_out, abridged_message_out, assistance_request.hospital)
      assistance_request.deactivate!
      first_responder.make_available!(incident)
      construct_and_send_status_available(first_responder, incident)
#       incident.end_incident!(:fr_cancel) if was_this_last_assigned_first_responder?(incident) && !incident.is_accepting_first_responders
      was_this_last_assigned_first_responder(incident, :fr_cancel)
      FirstResponderPerformanceDatum.cancel_message(first_responder, incident)
    when 1
      assistance_request.deactivate!
      first_responder.arrived_at_hospital!(incident)
      construct_and_send_status_available(first_responder, incident)
#       incident.end_incident!(:normal) if was_this_last_assigned_first_responder?(incident) && !incident.is_accepting_first_responders
      was_this_last_assigned_first_responder(incident, :normal)
      FirstResponderPerformanceDatum.confirmed_arrival_at_hospital(first_responder, incident)
    when 2
      message_out = I18n.t('oncall_md.msg_assistance_request',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        locale: first_responder.locale
      )
      abridged_message_out = I18n.t('oncall_md.msg_assistance_request_abrdgd',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        locale: first_responder.locale
      )
      send_message_to_oncall_mds(incident, message_out, abridged_message_out, assistance_request.hospital)
      send_message_to_other_frs(incident, message_out, abridged_message_out, first_responder)
      message_out =
        I18n.t('first_responder.msg_assistance_notified', locale: first_responder.locale) +
        I18n.t('first_responder.msg_confirm_hospital_arrival', locale: first_responder.locale)
      abridged_message_out =
        I18n.t('first_responder.msg_assistance_notified_abrdgd', locale: first_responder.locale) +
        I18n.t('first_responder.msg_confirm_hospital_arrival_abrdgd', locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
    when 3
      message_out = I18n.t('oncall_md.msg_delay_notice',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        delay: message_elements[1],
        locale: first_responder.locale
      )
      abridged_message_out = I18n.t('oncall_md.msg_delay_notice_abrdgd',
        name: first_responder.name,
        phone_number: first_responder.phone_number,
        delay: message_elements[1],
        locale: first_responder.locale
      )
      send_message_to_oncall_mds(incident, message_out, abridged_message_out, assistance_request.hospital)
      message_out =
        I18n.t('first_responder.msg_delay_notification_sent', locale: first_responder.locale) +
        I18n.t('first_responder.msg_confirm_hospital_arrival', locale: first_responder.locale)
      abridged_message_out =
        I18n.t('first_responder.msg_delay_notification_sent_abrdgd', minutes: message_elements[1], locale: first_responder.locale) +
        I18n.t('first_responder.msg_confirm_hospital_arrival_abrdgd', locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out, abridged_message_out)
    else
      handle_unknown_response(__LINE__, incident, first_responder, message)
    end
  end

# ########################################################################################












# ########################################################################################
#                                                                                        #
#                              Utility methods                                           #
#                                                                                        #
# ########################################################################################

# ########################################################################################
  def clean_assistance_requests_send_logout_message(first_responder)
    message_out = I18n.t('first_responder.logged_out', locale: first_responder.locale)
    OutgoingMessageService.send_text(first_responder.phone_number, message_out)
#   If FR is involved in incidents, remove FR from them
#   if it is last FR, end incident
    assistance_requests = AssistanceRequest.find_active_by_first_responder(first_responder)
    assistance_requests.each do |assistance_request|
      assistance_request.deactivate!
      incident = Incident.find(assistance_request.incident_id)
      MessageLog.log_message(incident, first_responder, false, message_out)
      if was_this_last_active_first_responder?(incident)
        incident.end_incident!(:fr_cancel)
      end
    end
#   If FR is not involved in incident, just send logout response.
    if assistance_requests.count == 0
      MessageLog.log_message(nil, first_responder, false, message_out)
    end
  end

# ########################################################################################
  def construct_and_send_hospital_text(first_responder, incident)
    data_center = DataCenter.find(incident.data_center_id)
    hospitals = Hospital.find_by_data_center(incident.data_center)
    hospital_text = ""
    if hospitals.length >= 1
      for i in 1..hospitals.length
        hospital_text += hospitals[i-1].to_s + ": " + i.to_s + "." +
          I18n.t('first_responder.msg_patient_eta', locale: first_responder.locale)
      end
    else
      hospital_text += I18n.t('first_responder.msg_patient_eta', locale: first_responder.locale)
    end
    message_out = I18n.t('first_responder.msg_confirm_transport', hospital_text: hospital_text, locale: first_responder.locale)
    abridged_message_out = I18n.t('first_responder.msg_confirm_transport_abrdgd', hospital_text: hospital_text, locale: first_responder.locale)
    OutgoingMessageService.send_text(first_responder.phone_number, message_out)
    MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
  end

# ########################################################################################
  def construct_and_send_status_available(first_responder, incident)
    data_center = DataCenter.find(incident.data_center_id)
    utc_offset = Setting.get_cached_setting(data_center, 'utc_offset').value

    # Get times for response info
    event_record = FirstResponderEventLog.where(
      first_responder_id: first_responder.id,
      incident_id: incident.id,
      to_state: 'enroute_to_site'
    ).order(:event_time_stamp).last
    if event_record.present?
      tsr = event_record.event_time_stamp.getlocal(utc_offset).strftime("%H:%M:%S")
    else
      tsr = nil
    end

    event_record = FirstResponderEventLog.where(
      first_responder_id: first_responder.id,
      incident_id: incident.id,
      to_state: 'on_site'
    ).order(:event_time_stamp).last
    if event_record.present?
      tos = event_record.event_time_stamp.getlocal(utc_offset).strftime("%H:%M:%S")
    else
      tos = nil
    end

    event_record = FirstResponderEventLog.where(
      first_responder_id: first_responder.id,
      incident_id: incident.id,
      to_state: 'transporting'
    ).order(:event_time_stamp).last
    if event_record.present?
      tst = event_record.event_time_stamp.getlocal(utc_offset).strftime("%H:%M:%S")
    else
      tst = nil
    end

    event_record = FirstResponderEventLog.where(
      first_responder_id: first_responder.id,
      incident_id: incident.id,
      to_state: 'available'
    ).order(:event_time_stamp).last
    if event_record.present?
      tah = event_record.event_time_stamp.getlocal(utc_offset).strftime("%H:%M:%S")
    else
      tah = nil
    end

    message_out = I18n.t('first_responder.msg_status_available',
      # Full time string: "%Y-%m-%d %H:%M:%S"
      time_start_response: tsr,
      time_on_scene: tos,
      time_start_transport: tst,
      time_at_hospital: tah,
      locale: first_responder.locale)
    abridged_message_out = I18n.t('first_responder.msg_status_available_abrdgd',
      # Full time string: "%Y-%m-%d %H:%M:%S"
      time_start_response: tsr,
      time_on_scene: tos,
      time_start_transport: tst,
      time_at_hospital: tah,
      locale: first_responder.locale)
    OutgoingMessageService.send_text(first_responder.phone_number, message_out)
    MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
  end

# ########################################################################################
  def first_first_responder_on_site(incident, first_responder)
    incident.incident_commander_id = first_responder.id
    incident.save
    number_of_vehicles = 0
    number_of_frs = 0
    assistance_requests = AssistanceRequest.where(incident_id: incident.id, state: AssistanceRequest.states[:assigned]).order(:eta)
    case assistance_requests.count
    when 0
      # Cannot happen
    when 1
      minutes_to_next_arrival = 0
    else
      minimum_seconds = Time.new(2100).utc.to_i
      assistance_requests.each do |assistance_request|
        other_first_responder = FirstResponder.find(assistance_request.first_responder_id)
        if other_first_responder.id != first_responder.id
          number_of_vehicles += 1 if other_first_responder.transportation_mode.to_sym == :transport_vehicle
          if (assistance_request.eta.to_i <=> minimum_seconds) == -1
            minimum_seconds = assistance_request.eta.to_i
          end
          number_of_frs += 1
        end
      end
      minimum_seconds = (minimum_seconds - Time.now.utc.to_i)
      minutes_to_next_arrival = minimum_seconds/60.round.to_i
    end
    incident.ic_on_scene_event!
    return [number_of_frs, number_of_vehicles, minutes_to_next_arrival]
  end

# ########################################################################################
  def fr_needed(incident, assistance_request)
    first_responder = FirstResponder.find(assistance_request.first_responder_id)
    assistance_request.state = :assigned #2
    assistance_request.save!
    message_out = I18n.t('first_responder.msg_confirm_arrival', location: incident.location, locale: first_responder.locale)
    abridged_message_out = I18n.t('first_responder.msg_confirm_arrival_abrdgd', location: incident.location, locale: first_responder.locale)
    OutgoingMessageService.send_text(first_responder.phone_number, message_out)
    MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
    first_responder.assigned_to_incident!(incident)
    # Clear all other AssistanceRequest records for this FR
    assistance_requests = AssistanceRequest.where(first_responder_id: first_responder.id).where.not(incident_id: incident.id)
    assistance_requests.each do |ar|
      ar.state = AssistanceRequest.states[:inactive]
      ar.save
    end
  end

# ########################################################################################
  def fr_unneeded(incident, assistance_request)
    first_responder = FirstResponder.find(assistance_request.first_responder_id)
    if first_responder.present?
      message_out = I18n.t('first_responder.msg_standby_available', incident_id: incident.id, locale: first_responder.locale)
      abridged_message_out = I18n.t('first_responder.msg_standby_available', incident_id: incident.id, locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(assistance_request.incident, first_responder, false, message_out, abridged_message_out, :fr_not_needed)
      assistance_request.state = :inactive #3
      assistance_request.save
    end
  end

# ########################################################################################
  def get_assistance_request_and_log_message(first_responder, message)
    assistance_request = AssistanceRequest.find_assigned_by_first_responder(first_responder)
    if !assistance_request.nil?
      incident = Incident.find(assistance_request.incident_id)
      MessageLog.log_message(incident, first_responder, true, message)
      return [assistance_request, incident]
    else
      MessageLog.log_message(nil, first_responder, true, message)
      return [nil, nil]
    end
  end

# ########################################################################################
  def ic_or_not(first_responder, message)
    assistance_request = AssistanceRequest.find_assigned_by_first_responder(first_responder)
    incident = Incident.find(assistance_request.incident_id)
    case incident.state.to_sym
    when :frs_assigned, :additional_resources_assigned  # Message goes to IC
      (number_of_frs, number_of_vehicles, minutes_to_next_arrival) = first_first_responder_on_site(incident, first_responder)
      message_out = I18n.t('first_responder.msg_additional_resources_request',
        number_of_frs: number_of_frs,
        number_of_vehicles: number_of_vehicles,
        minimum_eta: minutes_to_next_arrival,
        locale: first_responder.locale)
      abridged_message_out = I18n.t('first_responder.msg_additional_resources_request_abrdgd',
        number_of_frs: number_of_frs,
        number_of_vehicles: number_of_vehicles,
        minimum_eta: minutes_to_next_arrival,
        locale: first_responder.locale)
      OutgoingMessageService.send_text(first_responder.phone_number, message_out)
      MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
      first_responder.first_on_site!(incident)
    when :ic_on_scene # Message goes to other FRs
      construct_and_send_hospital_text(first_responder, incident)
      first_responder.arrived_on_site!(incident)
    when :waiting_for_additional_resources # Message goes to new IC
    end
  end

# ########################################################################################
  def send_help_request_to_first_responders(incident, initial_or_additional)
    data_center = DataCenter.find(incident.data_center_id)
    first_responders = FirstResponder.find_available_by_data_center(data_center)
    if first_responders.length > 0

      # Copy admin on initial requests for assistance
      if initial_or_additional == 'msg_request_for_assistance'
        message = I18n.t(
          'first_responder.' + initial_or_additional,
          incident_id: incident.id,
          incident_type: incident.subcategory_string,
          incident_location: incident.location,
          locale: ApplicationConfiguration.instance.admin_language
        )
        abridged_message = I18n.t(
          'first_responder.' + initial_or_additional + '_abrdgd',
          incident_id: incident.id,
          incident_type: incident.subcategory_string,
          incident_location: incident.location,
          locale: ApplicationConfiguration.instance.admin_language
        )
        administrators = Administrator.find_by_data_center(incident.data_center)
        if administrators.present?
          message = incident.data_center.name + "\n" + message
          administrators.each do |administrator|
            if administrator.phone_number.present?
              OutgoingMessageService.send_text(administrator.phone_number, message)
            end
            if administrator.email.present?
#               EmailService.send(administrator, 'Request for Assistance - Admin copy', message)
            end
            MessageLog.log_message(incident, administrator, false, message, abridged_message)
          end
        end
      end # initial_or_additional == 'msg_request_for_assistance'

      # Send request for assistance to FRs
      first_responders.each do |first_responder|
        message = I18n.t(
          'first_responder.' + initial_or_additional,
          incident_id: incident.id,
          incident_type: incident.subcategory_string,
          incident_location: incident.location,
          locale: first_responder.locale
        )
        abridged_message = I18n.t(
          'first_responder.' + initial_or_additional + '_abrdgd',
          incident_id: incident.id,
          incident_type: incident.subcategory_string,
          incident_location: incident.location,
          locale: first_responder.locale
        )
        first_responder.received_request_for_assistance!(incident)
        OutgoingMessageService.send_text(first_responder.phone_number, message)
        MessageLog.log_message(incident, first_responder, false, message, abridged_message, :request_for_assistance)


        # Deactivate all earlier requests, then add new one.
        assistance_requests = AssistanceRequest.where(incident_id: incident.id, first_responder_id: first_responder.id)
        assistance_requests.each do |ar|
          ar.deactivate!
        end
        assistance_request = AssistanceRequest.create(incident_id: incident.id, first_responder_id: first_responder.id)
        assistance_request.state = :received_request
        assistance_request.transportation_mode = first_responder.transportation_mode
        assistance_request.save!
      end # first_responders.each do |first_responder|

      # Update incident state
      incident.is_accepting_first_responders = true
      case initial_or_additional
      when 'msg_request_for_assistance'
        incident.state = Incident.states[:waiting_for_fr_responses]
      when 'msg_request_additional_resources'
        incident.state = Incident.states[:waiting_for_additional_resources]
      end
      incident.save!

      ResqueService.schedule_request_for_assistance_window(incident)
       Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Request for assistance window initiated at #{Time.zone.now.utc} " +
        "incident.id: #{incident.id} " +
        "type: #{initial_or_additional}"

    else # first_responders.length = 0
      first_responder = incident.incident_commander
      if first_responder.present?
        message = I18n.t('first_responder.msg_no_additional_resources_available', locale: first_responder.locale)
        abridged_message = I18n.t('first_responder.msg_no_additional_resources_available_abrdgd', locale: first_responder.locale)
        OutgoingMessageService.send_text(first_responder.phone_number, message)
        MessageLog.log_message(incident, first_responder, false, message, abridged_message)
#         incident.no_first_responders_available!(:no_frs)
      end

    end # first_responders.length
  end

# ########################################################################################
  def send_message_to_oncall_mds(incident, message_out, abridged_message_out, hospital)
    doctors = MedicalDoctor.find_by_hospital(hospital)
    doctors.each do |doctor|
      OutgoingMessageService.send_text(doctor.phone_number, message_out)
      MessageLog.log_message(incident, doctor, false, message_out, abridged_message_out)
    end
  end

# ########################################################################################
  def send_message_to_other_frs(incident, message_out, abridged_message_out, first_responder)
    assistance_requests = AssistanceRequest.find_active_by_incident(incident)
    assistance_requests.each do |ar|
      if ar.first_responder_id !=first_responder.id
        fr = FirstResponder.find(ar.first_responder_id)
        OutgoingMessageService.send_text(fr.phone_number, message_out)
        MessageLog.log_message(incident, fr, false, message_out, abridged_message_out)
      end
    end
  end

# ########################################################################################
  def was_this_last_assigned_first_responder?(incident)
    assistance_requests = AssistanceRequest.find_by_assigned_to_incident(incident)
    case assistance_requests.count
    when 0
      return true
    else
      return false
    end
  end

# ########################################################################################
  def was_this_last_assigned_first_responder(incident, instigator)
    assistance_requests = AssistanceRequest.find_by_assigned_to_incident(incident)
    if assistance_requests.count == 0 && !incident.is_accepting_first_responders
      if instigator == :no_addl_resources
        incident.no_first_responders_responded!(:no_addl_resources)
      else
        incident.end_incident!(instigator)
      end
      message_out = I18n.t('reporting_party.incident_ended',
        reason: I18n.t('system.completion_status.' + instigator.to_s),
        locale: incident.reporting_party.locale)
      OutgoingMessageService.send_text(incident.reporting_party.phone_number, message_out)
      MessageLog.log_message(incident, incident.reporting_party, false, message_out)
    end
  end

# ########################################################################################
  def validate_message?(message)
    message_elements = message.split('.')
    message_elements.each do |m|
      if m != m.gsub(/[^0-9]/,'') # Check that string contains only integers
        return false
      end
    end
    return true
  end

# ########################################################################################
  def validate_message_no_periods?(message)
    message_elements = message.split('.')
    if message_elements.length > 1
      return false
    else
      return true
    end
  end

# ########################################################################################
  def was_this_last_active_first_responder?(incident)
    return AssistanceRequest.find_active_by_incident(incident).count == 0
  end

# ########################################################################################
  def handle_unknown_response(line_num, incident, first_responder, message)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "Unknown response from line no.: #{line_num}"
    if incident.present?
      last_message = MessageLog.get_last_message_to_first_responder_for_incident(incident, first_responder)
    else
      last_message = MessageLog.get_last_message_to_first_responder(first_responder)
    end
    if last_message.nil?
      message_out = I18n.t('first_responder.msg_unexpected_message', last_message: message, locale: first_responder.locale)
      abridged_message_out = I18n.t('first_responder.msg_unexpected_message_abrdgd', last_message: message, locale: first_responder.locale)
    else
      message_out = I18n.t('first_responder.msg_unknown_response', last_message: last_message.message, locale: first_responder.locale)
      abridged_message_out = I18n.t('first_responder.msg_unknown_response_abrdgd', last_message: last_message.message, locale: first_responder.locale)
    end
    OutgoingMessageService.send_text(first_responder.phone_number, message_out)
    MessageLog.log_message(incident, first_responder, false, message_out, abridged_message_out)
  end

# ########################################################################################
  def handle_error(first_responder, incident, message, error_message)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "FR id: #{first_responder.id}" if !first_responder.nil?
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "incident id: #{incident.id}" if !incident.nil?
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "message: #{message}"  if !message.nil?
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "error_message: #{error_message}"  if !error_message.nil?
    OutgoingMessageService.send_text(ApplicationConfiguration.instance.admin_number, error_message)
    MessageLog.log_message(incident, first_responder, false, error_message)
  end

end

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "Debug" }


