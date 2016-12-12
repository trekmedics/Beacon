class ApplicationConfiguration
  include Singleton

  attr_accessor :data_center

  def admin_language
    return self.get_language(:admin_language)
  end

  def admin_number
    return Setting.get_cached_setting(self.data_center, :admin_number).try(:value)
  end

  def beacon_number
    return Setting.get_cached_setting(self.data_center, :beacon_number).try(:value)
  end

  def data_center_on?
    return Setting.get_cached_setting(self.data_center, :is_data_center_on).try(:value).try(:downcase) == 'true'
  end

  def message_language
    return self.get_language(:message_language)
  end

  def minimum_number_of_frs
    return Setting.get_cached_setting(self.data_center, :minimum_number_of_frs).try(:value)
  end

  def number_of_frs_to_allocate
    return Setting.get_cached_setting(self.data_center, :number_of_frs_to_allocate).try(:value)
  end

  def number_of_transport_vehicles_to_allocate
    return Setting.get_cached_setting(self.data_center, :number_of_transport_vehicles_to_allocate).try(:value)
  end

  def outgoing_message_server
    return Setting.get_cached_setting(self.data_center, :outgoing_message_server).try(:value)
  end

  def timeout_first_response_allocation
    return Setting.get_cached_setting(self.data_center, :timeout_first_response_allocation).try(:value)
  end

  def utc_offset
    return Setting.get_cached_setting(self.data_center, :utc_offset).try(:value)
  end

  def white_list_enabled?
    return Setting.get_cached_setting(self.data_center, :is_white_list_enabled).try(:value).try(:downcase) == 'true'
  end

 def self.generate_new_settings(data_center)
    ApplicationConfiguration.default_settings_list.each do |key, value|
      setting = Setting.new(data_center: data_center, key: key, value: value)
      if !setting.save
        Rails.logger.error "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}:#{File.basename(__FILE__)}:#{__LINE__}
          Error setting (data center: #{setting.data_center_id}, key: #{setting.key}) has not been created."
      end
    end
  end

protected

  def get_language(key)
    locale = Setting.get_cached_setting(self.data_center, key).try(:value)
    return I18n.available_locales.include?(locale.try(:to_sym)) ? locale : I18n.default_locale
  end

private

  def self.default_settings_list
    return [
      ['beacon_number', 'N/A'],
      ['admin_number', 'N/A'],
      ['message_language', 'en'],
      ['admin_language', 'en'],
      ['timeout_first_response_allocation', '1'],
      ['number_of_frs_to_allocate', '3'],
      ['minimum_number_of_frs', '1'],
      ['number_of_transport_vehicles_to_allocate', '1'],
      ['utc_offset', '-04:00'],
      ['is_white_list_enabled', 'true'],
      ['is_data_center_on', 'true'],
      ['outgoing_mail_server', 'Twilio']
    ]
  end
end
