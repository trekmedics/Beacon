module ErrorsHelper
  def self.serialize(error_hash)
    message = ''
    error_hash.each do |key, value|
      message += ' ' if message.present?
      message += "#{key.to_s.humanize} #{value.chomp}"
      message += '.' unless message.last == '.'
    end
    return { error: message }
  end
end
