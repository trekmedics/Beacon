class IncomingMessageService
########################################################
# Strategy:
#   Check first for a First Responder
#   If present, pass message to FirstResponder
#   If not,     pass message to IncidentManager
########################################################
  def self.process_message(phone_number, message)
    Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Message: ->#{message}<- from ->#{phone_number}<-"
    data_center = ApplicationConfiguration.instance.data_center
    Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "data_center: #{data_center}"
    if !data_center.present?
      exit
    end
    if !/\A\+/.match(phone_number).present?
      Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "phone_number: #{phone_number} needs a plus"
      phone_number = '+' + phone_number
      Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "phone_number: #{phone_number}"
    end
    first_responder = FirstResponder.find_by_phone_number(phone_number, data_center)
    if first_responder.present?
      FirstResponderManager.instance.process_first_responder_message(first_responder, message)
    elsif WhiteListedPhoneNumber.check_white_list(data_center, phone_number)
      IncidentManager.instance.process_reporting_party_message(phone_number, message)
    else
      OutgoingMessageService.send_text(phone_number, I18n.t('system.unrecognized_number'))
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "phone_number: #{phone_number}"
    end
  end
end

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
