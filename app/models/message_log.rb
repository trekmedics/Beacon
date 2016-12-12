class MessageLog < ActiveRecord::Base
  belongs_to :incident

  after_create :publish_message_log

  enum message_type: {
    no_message_type: 0,
    request_for_assistance: 1,
    request_for_assistance_reply: 2,
    fr_not_needed: 3,
    unregistered_number: 4
  }

  def self.log_message(incident, resource, is_incoming, message, abridged_message = '', message_type = :no_message_type)
    MessageLog.create(
      incident: incident,
      resource_type: resource.class.name,
      resource_id: resource.id,
      resource_name: resource.try(:name),
      resource_phone_number: (resource.is_a?(ReportingParty) && incident.try(:reporting_party).try(:is_admin)) ? 'Admin' : resource.try(:phone_number),
      is_incoming: is_incoming,
      message: message,
      abridged_message: abridged_message,
      message_type: message_type
    )
  end

  def self.format_message_log(message_log)
    formatted_message_log = []
    message_log.each { |log_item| formatted_message_log.push(log_item.format_for_admin_interface) }
    return formatted_message_log
  end

  def format_for_admin_interface
    data_center = ApplicationConfiguration.instance.data_center
    utc_offset = Setting.get_cached_setting(data_center, 'utc_offset').value
    message_log_hash = {
      time: self.created_at.getlocal(utc_offset).strftime("%H:%M:%S"),
      resource_id: self.resource_id,
      resource_type: self.resource_type.underscore,
      resource_name: self.resource_type == 'ReportingParty' ? 'Reporting Party' : self.resource_name,
      resource_phone_number: self.resource_phone_number,
      direction: self.is_incoming ? 'incoming' : 'outgoing',
      message_type: message_type
    }
    message_log_hash[:incident_id] = self.incident.id if self.incident.present?
    message_log_hash[:hash_key] = "#{self.resource_type.underscore}_#{self.resource_id}"
    message_log_hash[message_log_hash[:hash_key]] = self.abridged_message != '' ? self.abridged_message : self.message
    return message_log_hash
  end

  def self.get_last_message_to_first_responder(first_responder)
    messages = MessageLog.where(resource_type: 'FirstResponder', resource_id: first_responder.id, is_incoming: false)
    return messages.last
  end

  def self.get_last_message_to_first_responder_for_incident(incident, first_responder)
    messages = MessageLog.where(incident_id: incident.id, resource_type: 'FirstResponder', resource_id: first_responder.id, is_incoming: false)
    return messages.last
  end

  def self.get_unregistered_parties
    messages = MessageLog.where(resource_type: 'UnregisteredParty')
    return messages
  end

private

  def publish_message_log
    WebsocketRails[:incident].trigger(:message_log, self.format_for_admin_interface) if self.incident.present?
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "datetime: #{datetime}" }
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "data_center: #{data_center}" }
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "utc_offset: #{utc_offset}" }
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "result: #{result}" }
