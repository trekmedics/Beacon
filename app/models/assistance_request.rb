class AssistanceRequest < ActiveRecord::Base
  include AASM
  belongs_to :hospital
  belongs_to :incident
  belongs_to :first_responder

  enum state: {
    received_request: 0,
    responded: 1,
    assigned: 2,
    inactive: 3
  }

  enum transportation_mode: {
    not_specified: 0,
    no_vehicle: 1,
    non_transport_vehicle: 2,
    transport_vehicle: 3
  }

  aasm column: :state, enum: true, no_direct_assignment: false do
    state :received_request, initial: true
    state :responded
    state :assigned
    state :inactive

    event :received_request_event do
      after do
        self.publish_assistance_request_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'received_request_event')
      end
      transitions from: :received_request, to: :responded
    end

    event :responded_event do
      after do
        self.publish_assistance_request_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'responded_event')
      end
      transitions from: :responded, to: :assigned
    end

    event :assigned_event do
      after do
        self.publish_assistance_request_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'assigned_event')
      end
      transitions from: :assigned, to: :inactive
    end

    event :deactivate do
      after do
        self.publish_assistance_request_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'deactivate')
      end
      transitions to: :inactive
    end

  end

# ########################################################################################
  def set_transportation_mode(parameter)
    self.transportation_mode = parameter
    if self.transportation_mode_changed?
      if !self.save
        Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
          "Error setting transportation mode to (#{parameter})."
      end
    end
  end

# ########################################################################################
  def set_eta(parameter)
    self.eta = parameter
    if self.eta_changed?
      if !self.save
        Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
          "Error setting eta to (#{parameter})."
      end
    end
  end

# ########################################################################################
  def self.find_active_by_first_responder(first_responder)
    assistance_requests = AssistanceRequest.where(first_responder_id: first_responder.id).
      where.not(state: AssistanceRequest.states[:inactive]
    )
    return assistance_requests
  end

# ########################################################################################
  def self.find_active_by_incident(incident)
    assistance_requests = AssistanceRequest.where(incident: incident).
      where.not(state: AssistanceRequest.states[:inactive]
    )
    return assistance_requests
  end

# ########################################################################################
  def self.find_by_assigned_to_incident(incident)
    assistance_requests = AssistanceRequest.where(incident_id: incident.id,
      state: AssistanceRequest.states[:assigned]
    )
    return assistance_requests
  end

# ########################################################################################
  def self.find_by_first_responder(first_responder)
    assistance_requests = AssistanceRequest.where(first_responder_id: first_responder.id)
    return assistance_requests
  end

# ########################################################################################
  def self.find_by_first_responder_and_incident(first_responder, incident)
    assistance_requests = AssistanceRequest.where(incident_id: incident.id,
      first_responder_id: first_responder.id,
      state: AssistanceRequest.states[:received_request]
    )
    # There should only be one record
    case assistance_requests.count
    when 1
      return assistance_requests.first
    when 0
      return nil
    else
      return nil
    end
  end

# ########################################################################################
  def self.find_assigned_by_first_responder(first_responder)
    assistance_requests = AssistanceRequest.where(first_responder_id: first_responder.id,
      state: AssistanceRequest.states[:assigned]
    )
    # There should only be one record
    case assistance_requests.count
    when 1
      return assistance_requests.first
    when 0
      return nil
    else
      return nil
    end
  end

# ########################################################################################
  def self.find_non_responding_by_incident(incident)
    assistance_requests = AssistanceRequest.where(incident_id: incident.id).
      where.not(state: AssistanceRequest.states[:responded]
    )
    return assistance_requests
  end

# ########################################################################################
  def self.find_responding_by_incident(incident)
    assistance_requests = AssistanceRequest.where(incident_id: incident.id,
      state: AssistanceRequest.states[:responded]
    ).order(:eta)
    return assistance_requests
  end

protected

  def publish_assistance_request_update
    obj = { id: self.id, state: self.state }
    WebsocketRails[:request_for_assistance].trigger(:update, obj)
  end

  def handle_event_error(e, label)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      "#{label}: Exception: #{e.inspect}."
    OutgoingMessageService.send_text(ApplicationConfiguration.instance.admin_number, "Debug: #{e.inspect}.")
    # raise
  end

end
