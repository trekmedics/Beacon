require 'test_helper'

class MessageLogTest < ActiveSupport::TestCase
  def setup
    ApplicationConfiguration.instance.data_center = data_centers(:data_center_one)
    @first_responder = first_responders(:signed_in)
    @incident = incidents(:waiting_for_location_recent)
  end

  test 'no message type given' do
    message_log_item = MessageLog.log_message(@incident, @first_responder, false, 'test')
    assert message_log_item.message_type.to_sym == :no_message_type, "Asserting #{message_log_item.message_type.to_sym} == #{:no_message_type}"
  end

  test 'request for assistance message type given' do
    message_log_item = MessageLog.log_message(@incident, @first_responder, false, 'Request for Assistance', :request_for_assistance)
    assert message_log_item.message_type.to_sym == :request_for_assistance, "Asserting #{message_log_item.message_type.to_sym} == #{:no_message_type}"
  end

  test 'fr not needed message type given' do
    message_log_item = MessageLog.log_message(@incident, @first_responder, false, 'Other FRs responding', :fr_not_needed)
    assert message_log_item.message_type.to_sym == :fr_not_needed, "Asserting #{message_log_item.message_type.to_sym} == #{:fr_not_needed}"
  end
end
