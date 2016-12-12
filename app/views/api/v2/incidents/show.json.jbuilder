json.partial! 'incident', incident: @incident
json.partial! 'message_log', messages: @incident.message_log
json.partial! 'metrics', incident: @incident
