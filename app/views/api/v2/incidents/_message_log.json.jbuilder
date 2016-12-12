json.abridged_message_log messages do |message|
  json.extract! message, :abridged_message, :message, :is_incoming, :resource_name, :resource_type, :resource_phone_number, :created_at
end
