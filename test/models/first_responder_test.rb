require 'test_helper'

class FirstResponderTest < ActiveSupport::TestCase
  def setup
    ApplicationConfiguration.instance.data_center = data_centers(:data_center_one)
  end

  test 'sign in - successful' do
    first_responder = first_responders(:signed_out)
    assert first_responder.state == 'inactive'
    first_responder.log_in!
    assert first_responder.errors.blank?, first_responder.errors.messages
    assert first_responder.state == 'setting_transport_mode', "State is #{first_responder.state}."
  end

  test 'sign in - failure' do
    first_responder = first_responders(:signed_in_on_foot)
    assert first_responder.state == 'available'
    first_responder.log_in!
    assert first_responder.errors.blank?, first_responder.errors.messages
    assert first_responder.state == 'available'
  end

  test 'sign out - successful' do
    first_responder = first_responders(:signed_in_on_foot)
    assert first_responder.state == 'available'
    first_responder.log_out!
    assert first_responder.errors.blank?, first_responder.errors.messages
    assert first_responder.state == 'inactive', "State is #{first_responder.state}."
  end

  test 'sign out - failure' do
    first_responder = first_responders(:signed_out)
    assert first_responder.state == 'inactive'
    first_responder.log_out!
    assert first_responder.errors.blank?, first_responder.errors.messages
    assert first_responder.state == 'inactive'
  end

  test 'change phone number - success' do
    first_responder = first_responders(:signed_out)
    first_responder.phone_number = '+15555555550'
    assert first_responder.errors.blank?, first_responder.errors.messages
    assert first_responder.save == true
  end

  test 'change phone number - failure: logged in' do
    first_responder = first_responders(:signed_in)
    first_responder.phone_number = '+15555555550'
    assert first_responder.save == false
    assert first_responder.errors.messages.has_key?(:phone_number), "Error message keys: #{first_responder.errors.messages.keys}"
  end
end
