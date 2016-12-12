module ApplicationHelper
  def format_datetime(datetime)
    data_center = ApplicationConfiguration.instance.data_center
    utc_offset = Setting.get_cached_setting(data_center, 'utc_offset').value
    result = datetime.getlocal(utc_offset).strftime("%Y-%m-%d %H:%M:%S")
    return result
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "datetime: #{datetime}" }
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "data_center: #{data_center}" }
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "utc_offset: #{utc_offset}" }
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "result: #{result}" }
