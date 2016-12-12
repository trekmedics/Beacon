phone_number_list = []

FirstResponder.all.each do |fr|
  phone_number_list << { 'pn' => fr.phone_number, 'dc' => fr.data_center_id, 'type' => 'fr'}
end

WhiteListedPhoneNumber.all.each do |wh|
  phone_number_list << { 'pn' => wh.phone_number, 'dc' => wh.data_center_id, 'type' => 'wh'}
end

# puts phone_number_list

for i in 0 .. phone_number_list.length
  for j in i+1 ... phone_number_list.length
    if phone_number_list[i]['pn'] == phone_number_list[j]['pn']
      puts phone_number_list[i]['pn'] 
      puts "\t" + phone_number_list[i]['dc'].to_s + ":" + phone_number_list[i]['type']
      puts "\t" + phone_number_list[j]['dc'].to_s + ":" + phone_number_list[j]['type']
    end
  end
end

puts 'done'
