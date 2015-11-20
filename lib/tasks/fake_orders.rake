namespace :db do
	
  desc "Create 10 orders with for random companies"
  task :fake_orders => :environment do
	require 'populator'
	require 'ffaker'
	require 'faker'
		    Apartment::Tenant.switch!('ontimestaffing')
			Order.populate(10) do |order|
				order.company_id = 1...5
				order.agency_id = 18
				order.needed_by = Faker::Date.forward(10)
				order.title = FFaker::Company.position
				order.notes = FFaker::BaconIpsum.sentences
				order.number_needed = 1..4
				order.pay_range = [ "$8.10 - $10.00","$10.00 - $12.00","$12.00 - $15.00", "$15.00 - $18.00", "$18.00 - $22.00", "$22.00 +  "]
				order.est_duration = [ "Temp-to-Hire", "Direct-Hire", "Temporary"]
				order.dt_req = [ "None Required", "Yes - 5 panel screen", "Yes - 10 panel screen"]
				order.bg_check = [ "None Required", "Yes - No Felonies", "Yes - Case by case"]
				order.shift = [ "1st shift", "2nd shift", "3rd shift", "Flexible"]
				order.stwb = [true, false]
				order.heavy_lifting = [true, false]
				order.active = true
				order.urgent =  [true, false]
			end
	  puts 'All done!!!'
  end

  
  
end
  
  
  
  
