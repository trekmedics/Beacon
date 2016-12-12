class RequestForAssistanceWindowJob
  @queue = :request_for_assistance_window_queue

  def self.perform(params)
    Rails.logger.info "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n" +
      "params[incident_id]: #{params['incident_id']}"
    IncidentManager.instance.request_for_assistance_window_expired(params["incident_id"])
  end
end
