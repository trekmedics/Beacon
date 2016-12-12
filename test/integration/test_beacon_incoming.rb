require 'net/http'

# uri = URI('http://localhost:5000/incoming_messages')
# res = Net::HTTP.post_form(uri, 'From' => '+18005550000', 'Body' => '456')
# puts res.body
# # res = Net::HTTP.post_form(uri, 'From' => '+18005550000', 'Body' => '1')
# puts res.body


test_service = 'twilio'
test_service = 'bongo'
test_service = 'else'

def send_message(from_key, from_number, to_key, to_number, message_key, message)
  puts ''
  [from_key, from_number, to_key, to_number, message_key, message].each do |e|
    puts e
  end
  uri = URI('http://localhost:5000/incoming_messages')
  req = Net::HTTP::Post.new(uri)
  req.set_form_data(from_key => from_number, to_key => to_number, message_key => message)
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    puts 'Success: ' + res.inspect
  else
    puts 'Failed: ' + res.inspect
  end
end

if test_service == 'twilio'
  puts test_service
  send_message('From', '+18005550000', 'To', '+18005555000', 'Body', '123')
  send_message('From', '+18005550000', 'To', '+18005555000', 'Body', '1')
  send_message('From', '+18005550000', 'To', '+18005555000', 'Body', '456')
elsif test_service == 'bongo'
  puts test_service
  send_message('org', '+18005550000', 'dest', '+18005555000', 'message', '123')
  send_message('org', '+18005550000', 'dest', '+18005555000', 'message', '1')
  send_message('org', '+18005550000', 'dest', '+18005555000', 'message', '456')
else
  puts 'else'
  send_message('origin', '+18005550000', 'dest', '+18005555000', 'message', '456')
end

exit

data_center = DataCenter.find_by_name('Simulator')
ApplicationConfiguration.instance.data_center = data_center
first_responder = FirstResponder.where(data_center_id: data_center.id).first
OutgoingMessageService.send_ad_hoc_text_message(first_responder, 'test message 3')


