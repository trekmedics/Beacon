json.array! @incidents do |incident|
  json.partial! 'incident', incident: incident
end
