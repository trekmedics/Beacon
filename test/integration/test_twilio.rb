data_center = DataCenter.find_by_name('Simulator')
ApplicationConfiguration.instance.data_center = data_center

# +15005550001	This phone number is invalid.	21211
# +15005550002	Twilio cannot route to this number.	21612
# +15005550003	Your account doesn't have the international permissions necessary to SMS this number.	21408
# +15005550004	This number is blacklisted for your account.	21610
# +15005550009	This number is incapable of receiving SMS messages.	21614
# All Others	Any other phone number is validated normally.	Input-dependent


TwilioService.send_text('+15005550009', 'Test message')

# To see results,
# tail log/development.log
#
# e.g.
# [twilio_service.rb:15] e.message: The 'To' number +15005550001 is not a valid phone number.
# [twilio_service.rb:16] phone_number: +15005550001
# [twilio_service.rb:17] message: Test message
#   DataCenter Load (0.2ms)  SELECT  "data_centers".* FROM "data_centers" WHERE "data_centers"."name" = ? LIMIT 1  [["name", "Simulator"]]
# [twilio_service.rb:15] e.message: To number: +15005550009, is not a mobile number
# [twilio_service.rb:16] phone_number: +15005550009
# [twilio_service.rb:17] message: Test message

