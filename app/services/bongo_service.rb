require 'net/http'
require 'uri'

enc_uri = URI.escape("http://example.com/?a=\11\15")

module BongoService
  def self.send_text(phone_number, message)

    uri = URI.parse('http://www.bongolive.co.tz/api/sendSMS.php')
    params = {
        'sendername'  => ENV['BEACON_BONGO_SENDER_NAME'],
        'username'    => ENV['BEACON_BONGO_USER_NAME'],
        'password'    => ENV['BEACON_BONGO_PASSWORD'],
        'apikey'      => ENV['BEACON_BONGO_API_KEY'],
        'destnum'     => phone_number,
        'message'     => message
    }

    uri.query = URI.encode_www_form( params )
    res = Net::HTTP.get(uri)

    if res.to_i >= 0
      Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Bongo succeeded; response: #{res}"
    else
      Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Bongo failed; response: #{res}"
    end
  end
end

