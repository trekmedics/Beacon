class Incident < ActiveRecord::Base
  include AASM
  has_many :first_responders, through: :assistance_requests
  has_many :assistance_requests
  has_many :incident_event_log
  has_many :message_log, -> { order created_at: :asc }
  belongs_to :data_center
  belongs_to :reporting_party
  belongs_to :incident_commander, foreign_key: 'incident_commander_id', class_name: 'FirstResponder'

  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  after_initialize :set_managers
  after_initialize :set_default_values
  after_create :log_incident_creation
  after_create :publish_incident_create

  validates :data_center, presence: { message: I18n.t('activerecord.errors.models.incident.attributes.data_center.presence') }
  validate :first_responder_count_must_be_greater_than_or_equal_to_vehicle_count

  enum state: {
    request_received: 0,
    waiting_for_location: 1,
    waiting_for_fr_responses: 2,
    frs_assigned: 3,
    ic_on_scene: 4,       # ic = first FR on scene
    waiting_for_additional_resources: 5,
    additional_resources_assigned: 6,
    incident_complete: 7
  }

  enum completion_status: {
    normal: 0,
    admin_cancel: 1,
    rp_cancel: 2,
    fr_cancel: 3,
    no_frs: 4,
    no_addl_resources: 5
  }

  aasm column: :state, enum: true, no_direct_assignment: false do
    state :request_received, initial: true
    state :waiting_for_location
    state :waiting_for_fr_responses
    state :frs_assigned
    state :ic_on_scene
    state :waiting_for_additional_resources
    state :additional_resources_assigned
    state :incident_complete

    event :request_received_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'request_received_event')
      end
      transitions from: :request_received, to: :waiting_for_location
    end

    event :location_received_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'location_received_event')
      end
      transitions from: :waiting_for_location, to: :waiting_for_fr_responses
    end

    event :frs_assigned_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'frs_assigned_event')
      end
      transitions from: :waiting_for_fr_responses, to: :frs_assigned
    end

    event :additional_resources_assigned_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'additional_resources_assigned_event')
      end
      transitions from: :waiting_for_additional_resources, to: :additional_resources_assigned
    end

    event :ic_on_scene_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'ic_on_scene_event')
      end
      transitions from: :frs_assigned, to: :ic_on_scene
      transitions from: :additional_resources_assigned, to: :ic_on_scene
    end

    event :no_first_responders_responded do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.reporting_party.update(is_active: false) if self.reporting_party.present?
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'no_first_responders_responded')
      end
      transitions to: :incident_complete, after: Proc.new { |*args| set_completion_status(*args) }
    end

    event :no_first_responders_available do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.reporting_party.update(is_active: false) if self.reporting_party.present?
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'no_first_responders_responded')
      end
      transitions to: :incident_complete, after: Proc.new { |*args| set_completion_status(*args) }
    end

    event :cancel_incident do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.reporting_party.update(is_active: false) if self.reporting_party.present?
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'cancel_incident')
      end
      transitions to: :incident_complete, after: Proc.new { |*args| process_incident_cancel(*args) }
    end

    event :end_incident do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.log_event(old_state, self.state)
        self.reporting_party.update(is_active: false) if self.reporting_party.present?
        self.publish_incident_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'end_incident')
      end
      transitions to: :incident_complete, after: Proc.new { |*args| set_completion_status(*args) }
    end
  end

  aasm column: :completion_status, enum: true do
    state :normal
    state :admin_cancel
    state :rp_cancel
    state :fr_cancel
    state :no_frs
    state :no_addl_resources
  end

  def find_by_id(id)
    return Incident.find_by(id: id)
  end

  def find_by_reporting_party_id(reporting_party_id)
    return Incident.find_by(reporting_party_id: reporting_party_id)
  end

  def as_json(options = {})
    Jbuilder.new do |incident|
      incident.(self, :id, :state, :help_message, :location, :number_of_frs_to_allocate, :number_of_transport_vehicles_to_allocate, :comment)
      incident.state_string self.state_string
      incident.reporting_party(self.reporting_party, :id, :phone_number, :is_admin) if self.reporting_party.present?
      incident.incident_commander(self.incident_commander, :id, :name, :phone_number) if self.incident_commander.present?
      incident.formatted_message_log(MessageLog.format_message_log(self.message_log))
      data_center = ApplicationConfiguration.instance.data_center
      utc_offset = Setting.get_cached_setting(data_center, 'utc_offset').value
      incident.created_at_string self.created_at.getlocal(utc_offset).strftime("%Y-%m-%d %H:%M:%S")
      incident.updated_at_string self.updated_at.getlocal(utc_offset).strftime("%Y-%m-%d %H:%M:%S")
      incident.subcategory_string self.subcategory_string
    end.attributes!
  end

  def set_location(message)
    self.update(location: message)
  end

  def set_help_message(message)
    self.update(help_message: message)
  end

  def set_number_of_frs_to_allocate(message)
    self.update(number_of_frs_to_allocate: message)
  end

  def set_number_of_transport_vehicles_to_allocate(message)
    self.update(number_of_transport_vehicles_to_allocate: message)
  end

  def self.fetch_active_incidents(data_center)
    return Incident.where(data_center: data_center)
                   .where('state != ? OR created_at > ?', Incident.states[:incident_complete], 1.day.ago)
  end

  def get_completion_agent
    case completion_status.to_sym
    when :normal
      return 'Normal'
    when :admin_cancel
      return 'Admin'
    when :rp_cancel
      return 'Reporting Party'
    when :fr_cancel
      return 'First Responder'
    when :no_frs
      return 'No available First Responders'
    else
      return "Unknown"
    end
  end

  def update_comment(comment)
    self.update(comment: comment)
    self.publish_incident_update
  end

  def subcategory_string
    subcategory = Subcategory.find_by(id: self.subcategory_id)
    category = Category.find_by(id: subcategory.category_id) if !subcategory.nil?
    if !category.nil?
      cname = I18n.t('category.' + category.name + '.name', default: category.name).strip
      sname = I18n.t('category.' + category.name + '.' + subcategory.name, default: subcategory.name).strip
      rtn_value = cname + "-" + sname
    else
      rtn_value = ''
    end
    return rtn_value
  end

  def state_string
    str = "#{I18n.t("system.incident_state.#{self.state}")}"
    completion_status = self.completion_status ? "(" + I18n.t("system.completion_status." + self.completion_status) + ")" : ''
    return self.incident_complete? ? "#{str} #{completion_status}" : str
  end

  def request_for_assistance_count
    return self.message_log.where(message_type: MessageLog::message_types[:request_for_assistance]).count
  end

  def request_for_assistance_reply_count
    return self.message_log.where(message_type: MessageLog::message_types[:request_for_assistance_reply]).count
  end

  def confirmed_no_vehicle_count
    return self.confirmed_resource_with_transportation_mode_count(:no_vehicle)
  end

  def confirmed_non_transport_vehicle_count
    return self.confirmed_resource_with_transportation_mode_count(:non_transport_vehicle)
  end

  def confirmed_transport_vehicle_count
    return self.confirmed_resource_with_transportation_mode_count(:transport_vehicle)
  end

protected

  def publish_incident_create
    WebsocketRails[:incident].trigger(:create, self.as_json)
  end

  def publish_incident_update
    WebsocketRails[:incident].trigger(:update, self.as_json)
  end

  def log_event(from, to)
    IncidentEventLog.create(
      incident_id: self.id,
      from_state: from,
      to_state: to,
      event_time_stamp: Time.new
    )
  end

  def handle_event_error(e, label)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      ": incident.id: #{self.id} Exception: #{e.to_s}."
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
      ": incident.id: #{self.id} Exception: #{e.backtrace}."
    OutgoingMessageService.send_text(ApplicationConfiguration.instance.admin_number, "Debug: #{e.to_s}.")
    # raise
  end

  def append_comment(comment)
    if comment.present?
      new_comment = self.comment.present? ? "#{self.comment}  #{comment}" : comment
      self.update(comment: new_comment)
    end
  end

  def set_completion_status(message)
    self.update(completion_status: message)
  end

  def process_incident_cancel(message, cancel_comment)
    self.set_completion_status(message)
    self.append_comment(cancel_comment)
    @incident_manager.cleanup_after_cancel(self, cancel_comment)
  end

  def confirmed_resource_with_transportation_mode_count(transportation_mode)
    return self.assistance_requests.where.not(state: AssistanceRequest::states[:received_request])
                                   .where(transportation_mode: AssistanceRequest::transportation_modes[transportation_mode])
                                   .count
  end

private

  def set_managers
    @first_responder_manager = FirstResponderManager.instance
    @incident_manager = IncidentManager.instance
  end

  def set_default_values
    self.number_of_frs_to_allocate ||= ApplicationConfiguration.instance.number_of_frs_to_allocate
    self.number_of_transport_vehicles_to_allocate ||= ApplicationConfiguration.instance.number_of_transport_vehicles_to_allocate
  end

  def log_incident_creation
#    Rails.logger.tagged('Incident') { Rails.logger.info "Incident (id: #{self.id}) has been created." }
  end

  def first_responder_count_must_be_greater_than_or_equal_to_vehicle_count
    if self.number_of_frs_to_allocate < self.number_of_transport_vehicles_to_allocate
      self.errors.add(:base, I18n.t('activerecord.errors.models.incident.first_responder_count_must_be_greater_than_or_equal_to_vehicle_count'))
    end
  end
end
# Rails.logger.debug "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
#             "rtn_value: #{rtn_value}"
