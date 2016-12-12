class ResqueService
  def self.schedule_request_for_assistance_window(incident)
    window_in_minutes = ApplicationConfiguration.instance.timeout_first_response_allocation.try(:to_i).try(:minutes)

    if window_in_minutes.present?
#      Rails.logger.tagged('ResqueService') { Rails.logger.debug "Request for assistance window should expire at #{window_in_minutes.from_now}." }
       return Resque.enqueue_in(window_in_minutes, RequestForAssistanceWindowJob, { incident_id: incident.id })

    else
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Not able to determine request for assistance window."
    end
  end

  def self.schedule_simulation(simulation)
    return Resque.enqueue_in(5.seconds, SimulationJob, { simulation_id: simulation.id })
  end
end
