class FirstResponderReport
  attr_accessor :first_responder
  attr_accessor :number_of_original_requests
  attr_accessor :percentage_of_original_requests
  attr_accessor :number_of_original_request_replies
  attr_accessor :number_of_original_request_no_replies
  attr_accessor :percentage_of_original_request_replies
  attr_accessor :percentage_of_original_request_no_replies
  attr_accessor :average_original_confirm_time
  attr_accessor :number_of_additional_requests
  attr_accessor :number_of_additional_request_replies
  attr_accessor :number_of_additional_request_no_replies
  attr_accessor :percentage_of_additional_request_replies
  attr_accessor :percentage_of_additional_request_no_replies
  attr_accessor :average_additional_confirm_time
  attr_accessor :number_of_assigned_incidents
  attr_accessor :percentage_of_assigned_incidents
  attr_accessor :number_of_times_confirmed_on_scene
  attr_accessor :percentage_of_confirmed_on_scene
  attr_accessor :number_of_times_incident_commander
  attr_accessor :percentage_of_times_incident_commander
  attr_accessor :number_of_cancel_messages
  attr_accessor :percentage_of_cancel_messages
  attr_accessor :number_of_unable_to_locate_messages
  attr_accessor :percentage_of_unable_to_locate_messages
  attr_accessor :number_of_times_resources_requested
  attr_accessor :percentage_of_times_resources_requested
  attr_accessor :total_number_of_vehicles_requested
  attr_accessor :average_number_of_vehicles_requested
  attr_accessor :number_of_times_transport_confirmed
  attr_accessor :percentage_of_times_transport_confirmed
  attr_accessor :total_number_of_patients_transported
  attr_accessor :average_number_of_patients_transported
  attr_accessor :number_of_times_cancelled_after_on_scene
  attr_accessor :percentage_of_times_cancelled_after_on_scene
  attr_accessor :number_of_times_arrival_at_hospital_confirmed
  attr_accessor :percentage_of_times_arrival_at_hospital_confirmed
  attr_accessor :average_transport_time
  attr_accessor :number_of_incidents_completed
  attr_accessor :percentage_of_incidents_completed
  attr_accessor :average_completion_time

  def initialize(first_responder)
    self.first_responder = first_responder
    self.number_of_original_requests = self.calculate_number_of_original_requests
    self.percentage_of_original_requests = self.calculate_percentage_of_original_requests
    self.number_of_original_request_replies = self.calculate_number_of_original_request_replies
    self.number_of_original_request_no_replies = self.calculate_number_of_original_request_no_replies
    self.percentage_of_original_request_replies = self.calculate_percentage_of_original_request_replies
    self.percentage_of_original_request_no_replies = self.calculate_percentage_of_original_request_no_replies
    self.average_original_confirm_time = self.calculate_average_original_confirm_time

    self.number_of_additional_requests = self.calculate_number_of_additional_requests
    self.number_of_additional_request_replies = self.calculate_number_of_additional_request_replies
    self.number_of_additional_request_no_replies = self.calculate_number_of_additional_request_no_replies
    self.percentage_of_additional_request_replies = self.calculate_percentage_of_additional_request_replies
    self.percentage_of_additional_request_no_replies = self.calculate_percentage_of_additional_request_no_replies
    self.average_additional_confirm_time = self.calculate_average_additional_confirm_time

    self.number_of_assigned_incidents = self.calculate_number_of_assigned_incidents
    self.percentage_of_assigned_incidents = self.calculate_percentage_of_assigned_incidents

    self.number_of_times_confirmed_on_scene = self.calculate_number_of_times_confirmed_on_scene
    self.percentage_of_confirmed_on_scene = self.calculate_percentage_of_confirmed_on_scene
    self.number_of_times_incident_commander = self.calculate_number_of_times_incident_commander
    self.percentage_of_times_incident_commander = self.calculate_percentage_of_times_incident_commander

    self.number_of_cancel_messages = self.calculate_number_of_cancel_messages
    self.percentage_of_cancel_messages = self.calculate_percentage_of_cancel_messages
    self.number_of_unable_to_locate_messages = self.calculate_number_of_unable_to_locate_messages
    self.percentage_of_unable_to_locate_messages = self.calculate_percentage_of_unable_to_locate_messages

    self.number_of_times_resources_requested = self.calculate_number_of_times_resources_requested
    self.percentage_of_times_resources_requested = self.calculate_percentage_of_times_resources_requested
    self.total_number_of_vehicles_requested = self.calculate_total_number_of_vehicles_requested
    self.average_number_of_vehicles_requested = self.calculate_average_number_of_vehicles_requested

    self.number_of_times_transport_confirmed = self.calculate_number_of_times_transport_confirmed
    self.percentage_of_times_transport_confirmed = self.calculate_percentage_of_times_transport_confirmed
    self.total_number_of_patients_transported = self.calculate_total_number_of_patients_transported
    self.average_number_of_patients_transported = self.calculate_average_number_of_patients_transported

    self.number_of_times_cancelled_after_on_scene = self.calculate_number_of_times_cancelled_after_on_scene
    self.percentage_of_times_cancelled_after_on_scene = self.calculate_percentage_of_times_cancelled_after_on_scene

    self.number_of_times_arrival_at_hospital_confirmed = self.calculate_number_of_times_arrival_at_hospital_confirmed
    self.percentage_of_times_arrival_at_hospital_confirmed = self.calculate_percentage_of_times_arrival_at_hospital_confirmed
    self.average_transport_time = self.calculate_average_transport_time
    self.number_of_incidents_completed = self.calculate_number_of_incidents_completed
    self.percentage_of_incidents_completed = self.calculate_percentage_of_incidents_completed
    self.average_completion_time = self.calculate_average_completion_time
  end

protected

  def calculate_number_of_original_requests
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .count
  end

  def calculate_percentage_of_original_requests
    total_count = FirstResponderPerformanceDatum.all.count
    return total_count > 0 ? self.number_of_original_requests.to_f / total_count.to_f : nil
  end

  def calculate_number_of_original_request_replies
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_reply_original_request: true)
                                         .count
  end

  def calculate_number_of_original_request_no_replies
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_reply_original_request: [false, nil])
                                         .count
  end

  def calculate_percentage_of_original_request_replies
    return nil if self.number_of_original_requests == 0
    return self.number_of_original_request_replies.to_f / self.number_of_original_requests.to_f
  end

  def calculate_percentage_of_original_request_no_replies
    return nil if self.number_of_original_requests == 0
    return self.number_of_original_request_no_replies.to_f / self.number_of_original_requests.to_f
  end

  def calculate_average_original_confirm_time
    first_responder_performance_data = FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                                                     .where(did_reply_original_request: true)
    good_data_count = 0
    sum_of_differences = 0.0
    first_responder_performance_data.each do |datum|
      if datum.time_of_original_request_reply.present? && datum.time_of_original_request.present?
        good_data_count += 1
        sum_of_differences += datum.time_of_original_request_reply - datum.time_of_original_request
      end
    end
    return good_data_count > 0 ? sum_of_differences / good_data_count.to_f : nil
  end

  def calculate_number_of_additional_requests
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where.not(time_of_additional_request: nil)
                                         .count
  end

  def calculate_number_of_additional_request_replies
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_reply_additional_request: true)
                                         .count
  end

  def calculate_number_of_additional_request_no_replies
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where.not(time_of_additional_request: nil)
                                         .where(did_reply_additional_request: [false, nil])
                                         .count
  end

  def calculate_percentage_of_additional_request_replies
    return nil if self.number_of_additional_requests == 0
    return self.number_of_additional_request_replies.to_f / self.number_of_additional_requests.to_f
  end

  def calculate_percentage_of_additional_request_no_replies
    return nil if self.number_of_additional_requests == 0
    return self.number_of_additional_request_no_replies.to_f / self.number_of_additional_requests.to_f
  end

  def calculate_average_additional_confirm_time
    first_responder_performance_data = FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                                                     .where(did_reply_additional_request: true)
    good_data_count = 0
    sum_of_differences = 0.0
    first_responder_performance_data.each do |datum|
      if datum.time_of_additional_request_reply.present? && datum.time_of_additional_request.present?
        good_data_count += 1
        sum_of_differences += datum.time_of_additional_request_reply - datum.time_of_additional_request
      end
    end
    return good_data_count > 0 ? sum_of_differences / good_data_count.to_f : nil
  end

  def calculate_number_of_assigned_incidents
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(was_assigned: true)
                                         .count
  end

  def calculate_percentage_of_assigned_incidents
    number_of_replies = self.number_of_original_request_replies + self.number_of_additional_request_replies
    return nil unless number_of_replies > 0
    return self.number_of_assigned_incidents.to_f / number_of_replies.to_f
  end

  def calculate_number_of_times_confirmed_on_scene
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_confirm_on_scene: true)
                                         .count
  end

  def calculate_percentage_of_confirmed_on_scene
    return nil if self.number_of_assigned_incidents == 0
    return self.number_of_times_confirmed_on_scene.to_f / self.number_of_assigned_incidents.to_f
  end

  def calculate_number_of_times_incident_commander
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(was_incident_commander: true)
                                         .count
  end

  def calculate_percentage_of_times_incident_commander
    return nil if self.number_of_assigned_incidents == 0
    return self.number_of_times_incident_commander.to_f / self.number_of_assigned_incidents.to_f
  end

  def calculate_number_of_cancel_messages
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_cancel: true)
                                         .count
  end

  def calculate_percentage_of_cancel_messages
    return nil if self.number_of_assigned_incidents == 0
    return self.number_of_cancel_messages.to_f / self.number_of_assigned_incidents.to_f
  end

  def calculate_number_of_unable_to_locate_messages
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(was_unable_to_locate: true)
                                         .count
  end

  def calculate_percentage_of_unable_to_locate_messages
    return nil if self.number_of_assigned_incidents == 0
    return self.number_of_unable_to_locate_messages.to_f / self.number_of_assigned_incidents.to_f
  end

  def calculate_number_of_times_resources_requested
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_request_resources: true)
                                         .count
  end

  def calculate_percentage_of_times_resources_requested
    return nil if self.number_of_times_incident_commander == 0
    return self.number_of_times_resources_requested.to_f / self.number_of_times_incident_commander.to_f
  end

  def calculate_total_number_of_vehicles_requested
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_request_resources: true)
                                         .where.not(vehicles_requested: nil)
                                         .sum(:vehicles_requested)
  end

  def calculate_average_number_of_vehicles_requested
    return nil if self.number_of_times_incident_commander == 0
    return self.total_number_of_vehicles_requested.to_f / self.number_of_times_incident_commander.to_f
  end

  def calculate_number_of_times_transport_confirmed
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_confirm_transport: true)
                                         .count
  end

  def calculate_percentage_of_times_transport_confirmed
    return nil if self.number_of_times_confirmed_on_scene == 0
    return self.number_of_times_transport_confirmed.to_f / self.number_of_times_confirmed_on_scene.to_f
  end

  def calculate_total_number_of_patients_transported
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_confirm_transport: true)
                                         .where.not(patients_transported: nil)
                                         .sum(:patients_transported)
  end

  def calculate_average_number_of_patients_transported
    return nil if self.number_of_times_transport_confirmed == 0
    return self.total_number_of_patients_transported.to_f / self.number_of_times_transport_confirmed.to_f
  end

  def calculate_number_of_times_cancelled_after_on_scene
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_confirm_on_scene: true)
                                         .where(did_cancel: true)
                                         .count
  end

  def calculate_percentage_of_times_cancelled_after_on_scene
    return nil if self.number_of_times_confirmed_on_scene == 0
    return self.number_of_times_cancelled_after_on_scene.to_f / self.number_of_times_confirmed_on_scene.to_f
  end

  def calculate_number_of_times_arrival_at_hospital_confirmed
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_confirm_arrival: true)
                                         .count
  end

  def calculate_percentage_of_times_arrival_at_hospital_confirmed
    return nil if self.number_of_times_transport_confirmed == 0
    return self.number_of_times_arrival_at_hospital_confirmed.to_f / self.number_of_times_transport_confirmed.to_f
  end

  def calculate_average_transport_time
    first_responder_performance_data = FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                                                     .where(did_confirm_arrival: true)
                                                                     .where.not(time_of_confirm_transport: nil)
                                                                     .where.not(time_of_confirm_arrival: nil)
    return nil if first_responder_performance_data.length == 0
    sum_of_differences = 0.0
    first_responder_performance_data.each do |datum|
      sum_of_differences += datum.time_of_confirm_arrival - datum.time_of_confirm_transport
    end
    return sum_of_differences / first_responder_performance_data.length.to_f
  end

  def calculate_number_of_incidents_completed
    return FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                         .where(did_complete: true)
                                         .count
  end

  def calculate_percentage_of_incidents_completed
    return nil if self.number_of_assigned_incidents == 0
    return self.number_of_incidents_completed.to_f / self.number_of_assigned_incidents.to_f
  end

  def calculate_average_completion_time
    first_responder_performance_data = FirstResponderPerformanceDatum.where(first_responder: self.first_responder)
                                                                     .where(did_complete: true)
                                                                     .where.not(time_of_original_request: nil)
                                                                     .where.not(time_of_incident_complete: nil)
    return nil if first_responder_performance_data.length == 0
    sum_of_differences = 0.0
    first_responder_performance_data.each do |datum|
      sum_of_differences += datum.time_of_incident_complete - datum.time_of_original_request
    end
    return sum_of_differences / first_responder_performance_data.length.to_f
  end
end
