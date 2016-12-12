module OutgoingMessageService
  def self.send_text(phone_number, message)
    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "phone_number: #{phone_number}"
    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "message: #{message}"
    if ApplicationConfiguration.instance.data_center_on?

      if /\A\+\d{10,15}\z/.match(phone_number).present?

      	if ApplicationConfiguration.instance.outgoing_message_server == 'Twilio'
				  # Twilio
          Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__} \n\t" +
            "Sent via Twilio"
					if ENV['BEACON_TWILIO_AUTH_TOKEN'].present?
						if not OutgoingMessageService.is_a_fake_phone_number(phone_number)
							TwilioService.send_text(phone_number, message)
						else
							Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
								"Phone number (#{phone_number}) is fake."
						end
					end # Twilio

      	elsif ApplicationConfiguration.instance.outgoing_message_server == 'Bongo'
				  # Bongo
          Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__} \n\t" +
            "Sent via Bongo"
					if ENV['BEACON_BONGO_API_KEY'].present?
						if not OutgoingMessageService.is_a_fake_phone_number(phone_number)
							BongoService.send_text(phone_number, message)
						else
							Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
								"Phone number (#{phone_number}) is fake."
						end
					else
						Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
							"BEACON_BONGO_API_KEY is missing."
					end
				end # Bongo

      end # Valid phone_number


    else
#       Rails.logger.tagged('Info', 'OutgoingMessageService') { Rails.logger.info "Data Center is off; Message not sent to #{phone_number}." }
    end # data center on

  end

  def self.send_ad_hoc_text_message(first_responder, message)
    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "FR Phone number (#{first_responder.phone_number})"
    maximum_message_size = 140
    message = I18n.t('system.ad_hoc_message.preface', locale: first_responder.locale) + " \"#{message}\""
    if message.size <= maximum_message_size
      OutgoingMessageService.send_text(first_responder.phone_number, message)
    else
      error_message = I18n.t('system.ad_hoc_message.overage_error', name: first_responder.name, overage: message.size - maximum_message_size)
    end
    return error_message.blank?, error_message
  end

protected

  def self.is_a_fake_phone_number(phone_number)
    return /\A\+\d{1,5}800555\d{4}\z/.match(phone_number).present?
  end
end

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
