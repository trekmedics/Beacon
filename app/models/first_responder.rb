class FirstResponder < ActiveRecord::Base
  include AASM
  belongs_to :data_center
  has_many :incidents, through: :assistance_requests
  has_many :assistance_requests

  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  after_initialize :ensure_locale_is_set
  before_destroy :prevent_destroy

  validates :data_center, presence: { message: I18n.t('activerecord.errors.models.first_responder.attributes.data_center.presence') }
  validates :name, presence: { message: I18n.t('activerecord.errors.models.first_responder.attributes.name.presence') }
  validates :phone_number, format: { with: /\A\+\d{10,15}\z/, message: I18n.t('activerecord.errors.models.first_responder.attributes.phone_number.format') }
  validates :phone_number, uniqueness: { conditions: -> { where.not(state: 0) }, message: I18n.t('activerecord.errors.models.first_responder.attributes.phone_number.uniqueness') }
  validate :locale_is_valid
  validate :allow_phone_number_update_only_when_logged_out
  validate :phone_number_not_used_by_whitelist

  enum state: {
    disabled: 0,                          # ie, listed in db, but no longer current, cannot login
    inactive: 1,                          # ie: current, but not logged in
    setting_transport_mode: 2,            # ie: login message received, but transportation not set
    available: 3,                         # ie: logged-in, not assigned-to-any-incident
    enroute_to_site: 4,                   # ie: assigned to incident, enroute
    is_incident_commander_on_site: 5,     # ie: arrived on site first
    on_site: 6,                           # ie: arrived on site
    transporting: 7                       # ie: left site for hospital
  }

  enum transportation_mode: {
    not_specified: 0,
    no_vehicle: 1,
    non_transport_vehicle: 2,
    transport_vehicle: 3
  }

  aasm column: :state, enum: true, no_direct_assignment: false do
    state :disabled
    state :inactive, initial: true
    state :setting_transport_mode
    state :available
    state :enroute_to_site
    state :is_incident_commander_on_site
    state :on_site
    state :transporting

    event :log_in do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'log_in: ')
      end
      transitions from: :inactive, to: :setting_transport_mode, after: Proc.new { |*args| log_event(*args) }
    end

    event :admin_log_in do
      after do
        self.set_transportation_mode(:transport_vehicle )
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'admin_log_in: ')
      end
      transitions to: :available, after: Proc.new { |*args| log_event(*args) }
    end

    event :set_transport_mode do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'set_transport_mode: ')
      end
      transitions from: :setting_transport_mode, to: :available, after: Proc.new { |*args| log_event(*args) }
    end

    event :make_available do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'make_available: ')
      end
      transitions to: :available, after: Proc.new { |*args| log_event(*args) }
    end

    event :received_request_for_assistance do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'received_request_for_assistance: ')
      end
      transitions from: :available, to: :available, after: Proc.new { |*args| log_request_for_assistance_event(*args) }
    end

    event :assigned_to_incident do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'assigned_to_incident: ')
      end
      transitions from: :available, to: :enroute_to_site, after: Proc.new { |*args| log_assigned_to_incident_event(*args) }
    end

    event :first_on_site do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'first_on_site: ')
      end
      transitions from: :enroute_to_site, to: :is_incident_commander_on_site, after: Proc.new { |*args| log_first_on_site_event(*args) }
    end

    event :cannot_locate do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'cannot_locate: ')
      end
      transitions from: :enroute_to_site, to: :enroute_to_site, after: Proc.new { |*args| log_cannot_locate_event(*args) }
    end

    event :received_location_update do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'received_location_update: ')
      end
      transitions from: :enroute_to_site, to: :enroute_to_site, after: Proc.new { |*args| log_event(*args) }
    end

    event :arrived_on_site do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'arrived_on_site: ')
      end
      transitions from: :enroute_to_site, to: :on_site, after: Proc.new { |*args| log_on_site_event(*args) }
    end

    event :ic_on_site do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'ic_on_site: ')
      end
      transitions from: :is_incident_commander_on_site, to: :on_site, after: Proc.new { |*args| log_event(*args) }
    end

    event :is_transporting do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'is_transporting')
      end
      transitions from: :on_site, to: :transporting, after: Proc.new { |*args| log_event(*args) }
    end

    event :arrived_at_hospital do
      after do
        self.publish_first_responder_update
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'arrived_at_hospital: ')
      end
      transitions from: :transporting, to: :available, after: Proc.new { |*args| log_event(*args) }
      transitions from: :on_site, to: :available, after: Proc.new { |*args| log_event(*args) }
    end

    event :log_out do
      after do
        self.publish_first_responder_update
        self.transportation_mode = :not_specified
        FirstResponderManager.instance.clean_assistance_requests_send_logout_message(self)
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'log_out: ')
      end
      transitions to: :inactive, after: Proc.new { |*args| log_event(*args) }
    end

  end

  def set_transportation_mode(parameter)
    self.transportation_mode = parameter
    if self.transportation_mode_changed?
      if !self.save
        Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}
          Error setting transportation mode to (#{parameter})."
      end
    end
  end

  def soft_delete
    self.assign_attributes(state: 0)
    self.save(validate: false)
  end

  def self.find_by_id(id)
    return FirstResponder.find_by(id: id, state: [1..100])
  end

  def self.find_by_phone_number(phone_number, data_center)
    return FirstResponder.find_by(phone_number: phone_number, data_center: data_center, state: [1..100])
  end

  def self.find_by_phone_number_not_disabled(phone_number)
    return FirstResponder.find_by(phone_number: phone_number, state: [1..100])
  end

  def self.find_available_by_data_center(data_center)
    return FirstResponder.where(data_center: data_center, state: 3)
  end

  def log_message(message)
    MessageLog.log_message(nil, self, false, message)
  end

  def as_json(options = {})
    Jbuilder.new do |first_responder|
      first_responder.(self, :id, :state, :name, :phone_number, :locale)
      first_responder.state_string I18n.t("system.first_responder_state.#{self.state}")
      first_responder.transportation_mode FirstResponder::transportation_modes[self.transportation_mode]
      first_responder.transportation_mode_string I18n.t("first_responder.transportation_mode.modes.#{self.transportation_mode}")
    end.attributes!
  end

protected

  def publish_first_responder_update
    obj = { id: self.id, state: self.state, state_string: I18n.t("system.first_responder_state.#{self.state}"), transportation_mode: I18n.t("first_responder.transportation_mode.modes.#{self.transportation_mode}") }
    WebsocketRails[:first_responder].trigger(:update, obj)
  end

  def log_event(*args)
    if args.length == 1
      incident_id = args[0].id
    else
      inicident_id = nil
    end
    FirstResponderEventLog.create(
      first_responder_id: self.id,
      from_state: aasm.from_state,
      to_state: aasm.to_state,
      incident_id:incident_id,
      event_time_stamp: Time.new
    )
  end

  def log_request_for_assistance_event(*args)
    FirstResponderPerformanceDatum.request_for_assistance(self, args[0])
    self.log_event(*args)
  end

  def log_assigned_to_incident_event(*args)
    FirstResponderPerformanceDatum.assigned_to_incident(self, args[0])
    self.log_event(*args)
  end

  def log_on_site_event(*args)
    FirstResponderPerformanceDatum.confimed_on_scene(self, args[0])
    self.log_event(*args)
  end

  def log_first_on_site_event(*args)
    self.log_on_site_event(*args)
    FirstResponderPerformanceDatum.designated_incident_commander(self, args[0])
  end

  def log_cannot_locate_event(*args)
    FirstResponderPerformanceDatum.unable_to_locate_message(self, args[0])
    self.log_event(*args)
  end

  def handle_event_error(e, label)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}
      first_responder.id: #{self.id} Exception: #{e.to_s}."
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}
      first_responder.id: #{self.id} Exception: #{e.backtrace}."
    OutgoingMessageService.send_text(ApplicationConfiguration.instance.admin_number, "Debug: label: #{label} error_message: #{e.to_s}.")
  end

private

  def ensure_locale_is_set
    self.locale ||= ApplicationConfiguration.instance.message_language
  end

  def set_first_responder_manager
    @first_responder_manager = FirstResponderManager.instance
  end

  def locale_is_valid
    if self.locale.present? && !I18n.available_locales.include?(self.locale.to_sym)
      self.errors.add(:locale, I18n.t('activerecord.errors.models.first_responder.attributes.locale.locale_is_valid', first_responder_locale: self.locale))
    end
  end

  def allow_phone_number_update_only_when_logged_out
    if self.phone_number_changed? and not self.inactive?
      self.errors.add(:phone_number, I18n.t('activerecord.errors.models.first_responder.attributes.phone_number.logged_out'))
    end
  end

  def prevent_destroy
    raise StandardError.new('First Responder: Hard delete has been disabled, please use the soft_delete method.')
  end

  def phone_number_not_used_by_whitelist
    if WhiteListedPhoneNumber.where(phone_number: self.phone_number).present?
      self.errors.add(:phone_number, I18n.t('activerecord.errors.models.first_responder.attributes.phone_number.phone_number_used_by_whitelist'))
    end
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
