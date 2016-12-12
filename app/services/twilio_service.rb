require 'twilio-ruby'

module TwilioService
  def self.send_text(phone_number, message)
    return nil if Rails.env.test?
    twilio_client = Twilio::REST::Client.new(ENV['BEACON_TWILIO_ACCOUNT_SID'], ENV['BEACON_TWILIO_AUTH_TOKEN'])
    data = {
      from: ApplicationConfiguration.instance.beacon_number,
      to: phone_number,
      body: message
    }
    begin
      Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "data: #{data.inspect}"
      twilio_response = twilio_client.account.messages.create(data)
      Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "twilio_response: #{twilio_response.inspect}"
    rescue  Twilio::REST::RequestError => e
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "e.message: #{e.message}\n"
        "phone_number: #{phone_number}\n"
        "message: #{message}"
    end
  end
end

