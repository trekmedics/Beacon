class FirstResponderPerformanceDatum < ActiveRecord::Base
  belongs_to :first_responder
  belongs_to :incident
  belongs_to :hospital

  def self.request_for_assistance(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by(first_responder: first_responder, incident: incident)
    if first_responder_performance_datum.present?
      first_responder_performance_datum.update(time_of_additional_request: Time.now.utc)
    else
      FirstResponderPerformanceDatum.create(first_responder: first_responder, incident: incident, time_of_original_request: Time.now.utc)
    end
  end

  def self.request_for_assistance_reply(first_responder, incident, eta)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    if incident.waiting_for_fr_responses?
      first_responder_performance_datum.update(did_reply_original_request: true, time_of_original_request_reply: Time.now.utc, eta: eta)
    elsif incident.waiting_for_additional_resources?
      first_responder_performance_datum.update(did_reply_additional_request: true, time_of_additional_request_reply: Time.now.utc, eta: eta)
    else
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        "Unexpected incident state (#{incident.state})."
    end
  end

  def self.assigned_to_incident(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(was_assigned: true)
  end

  def self.confimed_on_scene(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(did_confirm_on_scene: true, time_of_confirm_on_scene: Time.now.utc)
  end

  def self.designated_incident_commander(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(was_incident_commander: true)
  end

  def self.cancel_message(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(did_cancel: true)
  end

  def self.unable_to_locate_message(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(was_unable_to_locate: true)
  end

  def self.requested_resources(first_responder, incident, vehicles_requested)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(did_request_resources: true, vehicles_requested: vehicles_requested)
  end

  def self.confirmed_transport(first_responder, incident, hospital, patients_transported, hospital_eta)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(did_confirm_transport: true, time_of_confirm_transport: Time.now.utc, hospital: hospital, patients_transported: patients_transported, hospital_eta: hospital_eta)
  end

  def self.no_transport(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(did_confirm_transport: false, did_complete: true, time_of_incident_complete: Time.now.utc)
  end

  def self.confirmed_arrival_at_hospital(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by_first_responder_and_incident(first_responder, incident)
    return nil if first_responder_performance_datum.blank?
    first_responder_performance_datum.update(did_confirm_arrival: true, time_of_confirm_arrival: Time.now.utc, did_complete: true, time_of_incident_complete: Time.now.utc)
  end

protected

  def self.find_by_first_responder_and_incident(first_responder, incident)
    first_responder_performance_datum = FirstResponderPerformanceDatum.find_by(first_responder: first_responder, incident: incident)
    if first_responder_performance_datum.blank?
      Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t"   +
        "Could not find performance data for first responder (#{first_responder.try(:id)}) and incident (#{incident.try(:id)})."
    end
    return first_responder_performance_datum
  end
end
