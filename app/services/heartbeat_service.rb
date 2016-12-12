require 'net/http'

module HeartbeatService

  def self.perform
    time = Time.new.utc
    uri = URI('http://theprescotts.com/beacon-monitor/update.php')
    time_string = time.strftime('%Y-%m-%dT%H:%M:%S%:z')
    res = Net::HTTP.post_form(uri, 'time_string' => time_string)
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "heartbeat time: #{time_string}" }
  end
end


# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
