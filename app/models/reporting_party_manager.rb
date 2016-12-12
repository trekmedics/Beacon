class ReportingPartyManagerRemoveThisClass
  include Singleton

  def process_reporting_party_message(phone_number, message)
    reporting_party = ReportingParty.find_or_create_by(phone_number: phone_number, is_active: true)
    incident = reporting_party.incident
    case incident.state.to_sym
    when :request_received
      incident.received_request_event!
    else
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Unexpected RP message: \"#{message}\"\nFrom: #{reporting_party.phone_number}"
    end

  end

  # TODO: May want to move this functionality into the reporting party state machine.
  def handle_outgoing_message(reporting_party, message)
    if reporting_party.help_request_received?
      OutgoingMessageService.send_text( \
        reporting_party.phone_number, I18n.t('reporting_party.provide_location', locale: reporting_party.locale))
        reporting_party.location_info_received_event!
      reporting_party.location_requested_event!  # transitions to location requested
    elsif reporting_party.location_requested?
      OutgoingMessageService.send_text(reporting_party.phone_number, I18n.t('reporting_party.location_provided', locale: reporting_party.locale))
      reporting_party.location_requested_event!  # transitions to location provided
    elsif reporting_party.additional_location_requested?
      # Not yet handled
      reporting_party.additional_location_info_received!
    else
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Unexpected RP message: \"#{message}\"\n" +
        "From: #{reporting_party.phone_number}"
    end
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
