require 'net/http'

Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "" } if ARGV[1]  == '9'
Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "********** Unknown number test *********" }
ActiveRecord::Base.logger = nil # Suppress output to log for every database action


to = '+18005557001'
from = '+18005557000'
body = 'Unknown number input'

puts "to:   #{to}"
puts "from: #{from}"
puts "body: #{body}"

if ENV['RAILS_ENV'] == 'development'
  uri = URI('http://localhost:5000/incoming_messages')
elsif ENV['RAILS_ENV'] == 'production'
  uri = URI('https://dispatch.trekmedics.org/incoming_messages')
else
  puts "Invalid environment: ENV['RAILS_ENV'] #{ENV['RAILS_ENV']}"
end
puts "uri:           #{uri}"

res = Net::HTTP.post_form(uri, 'To' => to, 'From' => from, 'Body' => body)

  rp = ReportingParty.find_by(phone_number: from)
  if rp.present?
    incident = Incident.find_by_reporting_party_id(rp.id)
  end
  test_label = 'unknown_number'
if incident.present? || rp.present?
  puts "Failed #{test_label}"
else
  puts "Passed #{test_label}"
end

