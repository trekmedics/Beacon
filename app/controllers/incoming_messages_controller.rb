class IncomingMessagesController < ApplicationController
  protect_from_forgery except: [:create]
  skip_before_action :authenticate_user!

  def create
    parameters = get_params
    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "parameters: #{parameters.to_s}"
    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "from: #{parameters['from']}" + "; message: #{parameters['body']}"
    if ApplicationConfiguration.instance.data_center.present? && parameters.present?
      IncomingMessageService.process_message(parameters['from'], parameters['body'])
    end
    render nothing: true
  end

private

  def configure_data_center
    parameters = get_params
    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "from: #{parameters['from']}" + "message: #{parameters['body']}"
    phone_number = parameters['from']
    if !/\A\+/.match(phone_number).present?
      Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "phone_number: #{phone_number} needs a plus"
      phone_number = '+' + phone_number
      Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "phone_number: #{phone_number}"
    end
    first_responder = FirstResponder.find_by_phone_number_not_disabled(phone_number)
    if first_responder.present?
      data_center = DataCenter.find(first_responder.data_center_id)
    else
      white_listed_phone_number = WhiteListedPhoneNumber.find_by_phone_number(phone_number)
      if white_listed_phone_number.present?
        data_center = DataCenter.find(white_listed_phone_number.data_center_id)
      else
        unregistered_party = UnregisteredParty.create(from: parameters['from'], to: parameters['to'], body: parameters['body'] )
        MessageLog.log_message(nil, unregistered_party, true, parameters['body'], :unregistered_number)
      end
    end
    ApplicationConfiguration.instance.data_center = data_center
  end

  def get_params

    Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "params: #{params.to_s}"
    if params['From'].present?
      #twilio
      parameters = {'from' => params['From'], 'to' => params['To'], 'body' => params['Body']}
      Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "twilio"
    elsif params['org'].present?
      # bongo
      parameters = {'from' => params['org'], 'to' => params['dest'], 'body' => params['message']}
      Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "bongo"
    else
      # error
      parameters = {'from' => '', 'to' => '', 'body' => ''}
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Incoming message not in twilio or bongo format. params: #{params.to_s}"

    end

    return parameters
  end

end


# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
