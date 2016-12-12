class ReportingParty < ActiveRecord::Base
  include AASM
  belongs_to :data_center
  has_one :incident

  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  after_initialize :ensure_locale_is_set
  after_initialize :ensure_incident_is_present

  validates :phone_number, presence: { message: I18n.t('activerecord.errors.models.reporting_party.attributes.phone_number.presence') }, unless: :is_admin
  with_options if: 'phone_number.present?' do |r|
    r.validates :phone_number, uniqueness: { conditions: -> { where(is_active: true) }, scope: :data_center, message: I18n.t('activerecord.errors.models.reporting_party.attributes.phone_number.uniqueness') }
    r.validates :phone_number, format: { with: /\A\+\d{10,15}\z/, message: I18n.t('activerecord.errors.models.reporting_party.attributes.phone_number.format') }
  end
  validate :locale_is_valid

  enum state: {
    request_received: 0,
    waiting_for_location: 1,
    waiting_for_location_update: 2,
    stand_by: 3
  }

  aasm column: :state, enum: true, no_direct_assignment: false do
    state :request_received, initial: true
    state :waiting_for_location
    state :waiting_for_location_update
    state :stand_by

    event :request_received_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
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
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'location_received_event')
      end
      transitions from: :waiting_for_location, to: :stand_by
    end

    event :location_update_requested_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'location_update_requested_event')
      end
      transitions from: :stand_by, to: :waiting_for_location_update
    end

    event :location_update_received_event do
      old_state = nil
      before do
        old_state = self.state
      end
      after do
        self.save
      end
      error do |e|
        self.handle_event_error(e, 'location_received_event')
      end
      transitions from: :waiting_for_location_update, to: :stand_by
    end

  end





  def request_location
    message_out = I18n.t('reporting_party.provide_location', locale: self.locale)
    OutgoingMessageService.send_text(self.phone_number, message_out)
    self.log_message(message_out)
  end

  def notify_assistance_has_been_contacted
    time_to_respond = ApplicationConfiguration.instance.timeout_first_response_allocation
    message_out = I18n.t('reporting_party.location_provided', time: time_to_respond, locale: self.locale)
    OutgoingMessageService.send_text(self.phone_number, message_out)
    self.log_message(message_out)
  end

  def self.find_by_id(id)
    return ReportingParty.find_by(id: id, is_active: true)
  end

  def self.find_by_phone_number(phone_number)
    return ReportingParty.find_by(phone_number: phone_number, is_active: true)
  end

protected

  def log_message(message)
    MessageLog.log_message(self.incident, self, false, message)
  end

  def handle_event_error(e, label)
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        label + ": reporting_party.id: #{self.id} Exception: #{e.to_s}."
    Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}\n\t" +
        label + ": reporting_party.id: #{self.id} Exception: #{e.backtrace}."
    OutgoingMessageService.send_text(ApplicationConfiguration.instance.admin_number, "Debug: #{e.to_s}.")
    # raise
    end

private

  def ensure_locale_is_set
    self.locale ||= ApplicationConfiguration.instance.message_language
  end

  def ensure_incident_is_present
    if self.incident.blank?
      self.incident = Incident.new(data_center: self.data_center)
      self.incident.number_of_frs_to_allocate = ApplicationConfiguration.instance.number_of_frs_to_allocate
      self.incident.number_of_transport_vehicles_to_allocate = ApplicationConfiguration.instance.number_of_transport_vehicles_to_allocate
      self.incident.save!
    end
  end

  def locale_is_valid
    if self.locale.present? && !I18n.available_locales.include?(self.locale.to_sym)
      self.errors.add(:locale, "is not available (#{self.locale}).")
    end
  end

  def set_location(message)
    self.incident.update(location: message)
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
