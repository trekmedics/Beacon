class Setting < ActiveRecord::Base
  belongs_to :data_center

  scope :by_data_center, ->(data_center) { where(data_center: data_center) }

  validates :data_center, presence: { message: I18n.t('activerecord.errors.models.setting.attributes.data_center.presence') }
  validates :key, presence: { message: I18n.t('activerecord.errors.models.setting.attributes.key.presence') }
  validates :key, uniqueness: { scope: :data_center, message: I18n.t('activerecord.errors.models.setting.attributes.key.uniqueness') }
  validates :value, presence: { message: I18n.t('activerecord.errors.models.setting.attributes.value.presence') }

  def self.get_cached_setting(data_center, key)
    raise StandardError.new('Setting requires a data center to be set.') if data_center.blank?
    cache_key = Setting.generate_cache_key(data_center.id, key)
    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      Setting.find_by(data_center: data_center, key: key)
    end
  end

  def set_cached_setting(value)
#     require 'set'
    allowed_languages = ['es', 'en', 'ht', 'sw'].to_set
    case self.key
    when 'utc_offset'
      if /\A[\+\-]\d\d:\d\d\Z/.match(value).nil?
        return false
      end
    when 'message_language'
      if  not allowed_languages.include?(value)
        return false
      end
    when 'admin_language'
      if  not allowed_languages.include?(value)
        return false
      end
    end

    success = self.update(value: value)
    cache_key = Setting.generate_cache_key(self.data_center_id, self.key)
    Rails.cache.delete(cache_key)
    return success
  end

private

  def self.generate_cache_key(data_center_id, key)
    return "setting/#{data_center_id}/#{key}"
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
