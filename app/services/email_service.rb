require 'net/smtp'

module EmailService

  def self.send(to, subject, body)

    message = "From: Beacon <wprescott@trekmedics.org>\n"
    message = message + "To: " + to + ">\n"
    message = message + "Subject: " + subject + "\n\n"
    message = message + body

    begin
      smtp = Net::SMTP.new 'email-smtp.us-east-1.amazonaws.com', 587
      smtp.set_debug_output 'log/development.log'
      smtp.enable_starttls
      response = Net::SMTP::Response.new
      smtp.start('email-smtp.us-east-1.amazonaws.com', ENV['BEACON_EMAIL_NAME'], ENV['BEACON_EMAIL_PWORD'], :plain) do
        smtp.send_message(message, 'wprescott@trekmedics.org', to)
      end
    rescue
      Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "smtp.inspect: #{smtp.inspect}" }
      Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "response.status: #{response.status}" }
      Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "response.string: #{response.string}" }
    end
  end
end


# export BEACON_EMAIL_NAME=AKIAIC73COBKVGWYJ6OQ
# export BEACON_EMAIL_PWORD=ApP+wn1HdzbqFHYbo6ywPOGDrpbYs55Yrv0Pa1Rd7m2V
# ses-smtp-user.20151212-000213
# SMTP Username: AKIAIC73COBKVGWYJ6OQ
# SMTP Password: ApP+wn1HdzbqFHYbo6ywPOGDrpbYs55Yrv0Pa1Rd7m2V
