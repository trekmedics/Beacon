echo "Running 2_incidents_1_fr"
bundle exec rails r test/integration/test_std_2_incidents_1_fr.rb > test_results.txt
echo "Running addl_res"
bundle exec rails r test/integration/test_std_addl_res.rb         >> test_results.txt
echo "Running cannot_locate"
bundle exec rails r test/integration/test_std_cannot_locate.rb    >> test_results.txt
echo "Running invalid_response"
bundle exec rails r test/integration/test_std_invalid_response.rb >> test_results.txt
echo "Running needs_assistance"
bundle exec rails r test/integration/test_std_needs_assistance.rb >> test_results.txt
echo "Running no_addl_res"
bundle exec rails r test/integration/test_std_no_addl_res.rb      >> test_results.txt
echo "Running no_frs"
bundle exec rails r test/integration/test_std_no_frs.rb          >> test_results.txt
echo "Running no_hospital"
bundle exec rails r test/integration/test_std_no_hospital.rb      >> test_results.txt
echo "Running no_transport"
bundle exec rails r test/integration/test_std_no_transport.rb     >> test_results.txt
echo "Running no_vehicles"
bundle exec rails r test/integration/test_std_no_vehicles.rb      >> test_results.txt
echo "Running unknown_number"
bundle exec rails r test/integration/test_std_unknown_number.rb   >> test_results.txt
echo "Running admin_created_incident"
bundle exec rails r test/integration/test_std_admin_created_incident.rb   >> test_results.txt

echo ''
grep 'Passed' test_results.txt
grep -A2 'Failed' test_results.txt
echo ''
rm test_results.txt

